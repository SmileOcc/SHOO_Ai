#!/usr/bin/env python3
"""Safe framework migration: move files + global package import rewrite."""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"

# (src relative to lib, dst relative to lib)
MOVES: list[tuple[str, str]] = [
    # core storage / cache / network
    ("core/storage/hos_local_storage.dart", "core/storage/key_value/hos_local_storage.dart"),
    ("core/storage/hos_secure_storage.dart", "core/storage/secure/hos_secure_storage.dart"),
    ("core/storage/hos_image_cache_manager.dart", "core/cache/hos_image_cache_manager.dart"),
    ("core/network/hos_auth_interceptor.dart", "core/network/interceptors/hos_auth_interceptor.dart"),
    ("core/network/hos_network_log_interceptor.dart", "core/network/interceptors/hos_network_log_interceptor.dart"),
    ("core/network/hos_connectivity_service.dart", "core/network/hos_network_info.dart"),
]


def pkg(rel: str) -> str:
    return f"package:shoo/{rel}"


def move_all() -> None:
    for src, dst in MOVES:
        s, d = LIB / src, LIB / dst
        if not s.exists():
            if d.exists():
                continue
            print(f"SKIP missing {src}")
            continue
        d.parent.mkdir(parents=True, exist_ok=True)
        s.rename(d)
        print(f"MOVED {src} -> {dst}")


def rewrite_all() -> None:
    reps: list[tuple[str, str]] = []
    for src, dst in MOVES:
        reps.append((pkg(src), pkg(dst)))
    # relative patterns seen in codebase
    reps.extend(
        [
            ("../storage/hos_local_storage.dart", pkg("core/storage/key_value/hos_local_storage.dart")),
            ("../../storage/hos_local_storage.dart", pkg("core/storage/key_value/hos_local_storage.dart")),
            ("../storage/hos_secure_storage.dart", pkg("core/storage/secure/hos_secure_storage.dart")),
            ("../../storage/hos_secure_storage.dart", pkg("core/storage/secure/hos_secure_storage.dart")),
            ("../storage/hos_image_cache_manager.dart", pkg("core/cache/hos_image_cache_manager.dart")),
            ("../../storage/hos_image_cache_manager.dart", pkg("core/cache/hos_image_cache_manager.dart")),
            ("hos_auth_interceptor.dart", "interceptors/hos_auth_interceptor.dart"),
            ("hos_network_log_interceptor.dart", "interceptors/hos_network_log_interceptor.dart"),
            ("hos_connectivity_service.dart", "hos_network_info.dart"),
            ("SHOConnectivityService", "SHONetworkInfo"),
            ("connectivityServiceProvider", "networkInfoProvider"),
        ]
    )
    for root in (LIB, ROOT / "test"):
        if not root.exists():
            continue
        for p in root.rglob("*.dart"):
            text = p.read_text(encoding="utf-8")
            orig = text
            for old, new in reps:
                text = text.replace(old, new)
            if text != orig:
                p.write_text(text, encoding="utf-8")


def patch_moved_internals() -> None:
    patches = {
        LIB / "core/storage/key_value/hos_local_storage.dart": [
            ("import '../constants/", "import 'package:shoo/core/constants/"),
            ("import '../errors/", "import 'package:shoo/core/errors/"),
            (
                "import '../../features/toolbox/data/hos_reading_storage_keys.dart",
                "import 'package:shoo/features/toolbox/data/hos_reading_storage_keys.dart",
            ),
            (
                "import '../../features/toolbox/data/hos_music_storage_keys.dart",
                "import 'package:shoo/features/toolbox/data/hos_music_storage_keys.dart",
            ),
            (
                "import '../../features/toolbox/data/hos_video_storage_keys.dart",
                "import 'package:shoo/features/toolbox/data/hos_video_storage_keys.dart",
            ),
        ],
        LIB / "core/storage/secure/hos_secure_storage.dart": [
            ("import '../constants/", "import 'package:shoo/core/constants/"),
        ],
        LIB / "core/network/interceptors/hos_auth_interceptor.dart": [
            ("import '../errors/", "import 'package:shoo/core/errors/"),
        ],
        LIB / "core/network/interceptors/hos_network_log_interceptor.dart": [
            ("import '../debug/", "import 'package:shoo/core/debug/"),
            ("import '../logging/", "import 'package:shoo/core/logging/"),
        ],
        LIB / "core/cache/hos_image_cache_manager.dart": [
            ("import '../config/", "import 'package:shoo/core/config/"),
            ("import '../logging/", "import 'package:shoo/core/logging/"),
            ("import '../errors/", "import 'package:shoo/core/errors/"),
        ],
    }
    for path, rules in patches.items():
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        for old, new in rules:
            text = text.replace(old, new)
        path.write_text(text, encoding="utf-8")


def analyze() -> int:
    r = subprocess.run(["dart", "analyze", "lib", "test"], cwd=ROOT, capture_output=True, text=True)
    errors = [ln for ln in r.stdout.splitlines() if ln.strip().startswith("error -")]
    print(f"errors: {len(errors)}")
    if errors[:5]:
        print("\n".join(errors[:5]))
    return len(errors)


def re_imports(text: str) -> list[str]:
    return re.findall(r"import '([^']+)'", text)


def _resolve_pres_import(feat: str, name: str, from_layer: str) -> str | None:
    pres = LIB / "features" / feat / "presentation"
    for layer in ("state", "widgets", "pages"):
        if (pres / layer / name).exists():
            if from_layer == layer:
                return f"package:shoo/features/{feat}/presentation/{layer}/{name}"
            return f"package:shoo/features/{feat}/presentation/{layer}/{name}"
    for sub in ("music", "video"):
        for layer in ("state", "widgets", "pages"):
            if (pres / sub / layer / name).exists():
                return f"package:shoo/features/{feat}/presentation/{sub}/{layer}/{name}"
    return None


def migrate_feature(feat: str) -> None:
    base = LIB / "features" / feat
    if not base.exists():
        return

    moves: list[tuple[str, str]] = []
    domain = base / "domain"
    entities = domain / "entities"
    if domain.is_dir():
        entities.mkdir(parents=True, exist_ok=True)
        for f in list(domain.glob("*.dart")):
            moves.append((f"features/{feat}/domain/{f.name}", f"features/{feat}/domain/entities/{f.name}"))

    data = base / "data"
    if data.is_dir():
        remote = data / "datasources" / "remote"
        local = data / "datasources" / "local"
        repos = data / "repositories"
        remote.mkdir(parents=True, exist_ok=True)
        local.mkdir(parents=True, exist_ok=True)
        repos.mkdir(parents=True, exist_ok=True)
        for f in list(data.glob("*.dart")):
            n = f.name
            if n.endswith("_api.dart"):
                dst = f"features/{feat}/data/datasources/remote/{n.replace('_api.dart', '_remote_ds.dart')}"
            elif "storage" in n or n.endswith("_keys.dart") or n.endswith("_paths.dart"):
                dst = f"features/{feat}/data/datasources/local/{n}"
            elif n.endswith("_repository.dart"):
                dst = f"features/{feat}/data/repositories/{n.replace('_repository.dart', '_repository_impl.dart')}"
            elif n.endswith("_reconcile_service.dart"):
                dst = f"features/{feat}/data/repositories/{n}"
            elif n.endswith("_service.dart"):
                dst = f"features/{feat}/data/repositories/{n.replace('_service.dart', '_service_impl.dart')}"
            else:
                dst = f"features/{feat}/data/datasources/remote/{n}"
            moves.append((f"features/{feat}/data/{n}", dst))

    pres = base / "presentation"
    if pres.is_dir():
        for sub in ("pages", "widgets", "state"):
            (pres / sub).mkdir(parents=True, exist_ok=True)

        def classify(name: str) -> str:
            if name in ("study_home_page.dart", "study_article_page.dart"):
                return "pages"
            if name.endswith(
                (
                    "_page.dart",
                    "_route_page.dart",
                    "onboarding_page.dart",
                    "splash_page.dart",
                )
            ):
                return "pages"
            if name.endswith(
                (
                    "_controller.dart",
                    "_provider.dart",
                    "_paged_controller.dart",
                    "_notifier.dart",
                    "_reporter.dart",
                    "_recorder.dart",
                    "_route_state.dart",
                    "_nav_observer.dart",
                    "hos_auth_token_provider.dart",
                    "hos_session_provider.dart",
                )
            ):
                return "state"
            return "widgets"

        for f in list(pres.glob("*.dart")):
            bucket = classify(f.name)
            moves.append(
                (f"features/{feat}/presentation/{f.name}", f"features/{feat}/presentation/{bucket}/{f.name}")
            )
        for sub in ("music", "video"):
            sd = pres / sub
            if not sd.is_dir():
                continue
            for f in list(sd.glob("*.dart")):
                bucket = classify(f.name)
                (sd / bucket).mkdir(parents=True, exist_ok=True)
                moves.append(
                    (
                        f"features/{feat}/presentation/{sub}/{f.name}",
                        f"features/{feat}/presentation/{sub}/{bucket}/{f.name}",
                    )
                )

    # execute moves
    for src, dst in moves:
        s, d = LIB / src, LIB / dst
        if not s.exists():
            continue
        d.parent.mkdir(parents=True, exist_ok=True)
        s.rename(d)

    # global rewrites for this feature
    reps: list[tuple[str, str]] = []
    for src, dst in moves:
        reps.append((pkg(src), pkg(dst)))
    reps.append((f"features/{feat}/domain/", f"features/{feat}/domain/entities/"))
    reps.append((f"hos_{feat}_api.dart", f"hos_{feat}_remote_ds.dart"))
    reps.append((f"hos_{feat}_repository.dart", f"hos_{feat}_repository_impl.dart"))
    if feat == "auth":
        reps.append(
            (
                pkg("features/auth/data/datasources/remote/hos_auth_remote_ds.dart"),
                pkg("features/auth/data/datasources/remote/hos_auth_remote_ds.dart"),
            )
        )
    for root in (LIB, ROOT / "test"):
        if not root.exists():
            continue
        for p in root.rglob("*.dart"):
            text = p.read_text(encoding="utf-8")
            orig = text
            for old, new in reps:
                text = text.replace(old, new)
            if text != orig:
                p.write_text(text, encoding="utf-8")

    # data layer relative imports
    data = base / "data"
    if data.is_dir():
        for p in data.rglob("*.dart"):
            text = p.read_text(encoding="utf-8")
            orig = text
            text = text.replace(
                f"import '../domain/",
                f"import 'package:shoo/features/{feat}/domain/entities/",
            )
            text = text.replace(
                f"import '../../domain/",
                f"import 'package:shoo/features/{feat}/domain/entities/",
            )
            text = re.sub(
                rf"import 'hos_{feat}_remote_ds.dart'",
                f"import 'package:shoo/features/{feat}/data/datasources/remote/hos_{feat}_remote_ds.dart'",
                text,
            )
            text = re.sub(
                r"import 'hos_([a-z_]+)\.dart'",
                lambda m: (
                    f"import 'package:shoo/features/{feat}/data/datasources/remote/hos_{m.group(1)}.dart'"
                    if (data / "datasources" / "remote" / f"hos_{m.group(1)}.dart").exists()
                    else m.group(0)
                ),
                text,
            )
            # repository impl sibling imports
            if "repositories" in p.parts:
                for sub in ("remote", "local"):
                    ds = data / "datasources" / sub
                    if not ds.is_dir():
                        continue
                    for f in ds.glob("*.dart"):
                        text = text.replace(
                            f"import '{f.name}'",
                            f"import 'package:shoo/features/{feat}/data/datasources/{sub}/{f.name}'",
                        )
                        text = text.replace(
                            f"import '../datasources/{sub}/{f.name}'",
                            f"import 'package:shoo/features/{feat}/data/datasources/{sub}/{f.name}'",
                        )
            if text != orig:
                p.write_text(text, encoding="utf-8")
    for p in base.rglob("*.dart"):
        text = p.read_text(encoding="utf-8")
        orig = text
        for depth in ("../../../", "../../../../", "../../../../../"):
            text = text.replace(f"import '{depth}core/", "import 'package:shoo/core/")
            text = text.replace(f"import '{depth}app/", "import 'package:shoo/app/")
            text = text.replace(f"import '{depth}l10n/", "import 'package:shoo/l10n/")
        if text != orig:
            p.write_text(text, encoding="utf-8")

    # presentation sibling imports
    for layer, dirs in (
        ("pages", ("../state/", "../widgets/")),
        ("widgets", ("../state/",)),
        ("state", ("../widgets/",)),
    ):
        folder = pres / layer
        if not folder.is_dir():
            continue
        for p in folder.rglob("*.dart"):
            text = p.read_text(encoding="utf-8")
            orig = text
            for imp in re_imports(text):
                if imp.startswith("package:") or imp.startswith("../") or imp.startswith("../../domain"):
                    continue
                if not imp.startswith("hos_"):
                    continue
                target = _resolve_pres_import(feat, imp, layer)
                if target:
                    text = text.replace(f"import '{imp}'", f"import '{target}'")
            if text != orig:
                p.write_text(text, encoding="utf-8")


def main() -> None:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "all"
    if cmd in ("core", "all"):
        move_all()
        rewrite_all()
        patch_moved_internals()
        if analyze() > 0:
            sys.exit(1)
    if cmd in ("features", "all"):
        for feat in sorted((LIB / "features").iterdir()):
            if feat.is_dir():
                print(f"=== feature {feat.name} ===")
                migrate_feature(feat.name)
        if analyze() > 0:
            sys.exit(1)
    print("OK")


if __name__ == "__main__":
    main()
