#!/usr/bin/env python3
"""One-shot framework directory migration for SHOO. Run from repo root."""
from __future__ import annotations

import os
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"

PAGE_SUFFIXES = (
    "_page.dart",
    "_route_page.dart",
    "onboarding_page.dart",
    "splash_page.dart",
)
STATE_SUFFIXES = (
    "_controller.dart",
    "_provider.dart",
    "_paged_controller.dart",
    "_notifier.dart",
    "_session.dart",
    "_reporter.dart",
    "_recorder.dart",
    "_route_state.dart",
    "_nav_observer.dart",
    "hos_auth_token_provider.dart",
    "hos_session_provider.dart",
)


def is_generated(name: str) -> bool:
    return name.endswith(".freezed.dart") or name.endswith(".g.dart")


def classify_presentation(path: Path, name: str) -> str:
    if name in ("study_home_page.dart", "study_article_page.dart"):
        return "pages"
    if any(name.endswith(s) for s in PAGE_SUFFIXES):
        return "pages"
    if any(name.endswith(s) for s in STATE_SUFFIXES) or name.endswith("_session.dart"):
        return "state"
    if name.endswith("_page.dart"):
        return "pages"
    # helpers tied to pages
    if name in (
        "hos_download_preview_helper.dart",
        "hos_download_task_status.dart",
        "hos_txt_reader_pagination.dart",
        "hos_txt_reader_theme.dart",
        "hos_download_file_type_ui.dart",
    ):
        return "widgets"
    return "widgets"


def migrate_feature(feature: Path) -> list[tuple[str, str]]:
    moves: list[tuple[str, str]] = []
    name = feature.name

    # domain -> domain/entities
    domain = feature / "domain"
    if domain.is_dir():
        entities = domain / "entities"
        entities.mkdir(parents=True, exist_ok=True)
        for f in list(domain.iterdir()):
            if f.is_file() and f.parent == domain:
                dst = entities / f.name
                if f != dst:
                    shutil.move(str(f), str(dst))
                    moves.append((str(f.relative_to(ROOT)), str(dst.relative_to(ROOT))))

    # data layer
    data = feature / "data"
    if data.is_dir():
        remote = data / "datasources" / "remote"
        local = data / "datasources" / "local"
        repos = data / "repositories"
        remote.mkdir(parents=True, exist_ok=True)
        local.mkdir(parents=True, exist_ok=True)
        repos.mkdir(parents=True, exist_ok=True)

        for f in list(data.iterdir()):
            if not f.is_file():
                continue
            n = f.name
            if n.endswith("_api.dart") or n.endswith("_engine.dart"):
                new_name = n.replace("_api.dart", "_remote_ds.dart")
                if n.endswith("_engine.dart"):
                    new_name = n
                dst = remote / new_name
            elif "storage" in n or n.endswith("_paths.dart") or n.endswith("_keys.dart"):
                dst = local / n
            elif n.endswith("_repository.dart") or n.endswith("_service.dart"):
                dst = repos / n.replace("_repository.dart", "_repository_impl.dart").replace(
                    "_service.dart", "_service_impl.dart"
                )
            elif n.endswith("_reconcile_service.dart"):
                dst = repos / n.replace(".dart", "_impl.dart")
            else:
                dst = remote / n
            if f != dst:
                shutil.move(str(f), str(dst))
                moves.append((str(f.relative_to(ROOT)), str(dst.relative_to(ROOT))))

    # presentation
    pres = feature / "presentation"
    if pres.is_dir():
        for sub in ["pages", "widgets", "state"]:
            (pres / sub).mkdir(parents=True, exist_ok=True)

        def move_pres_file(f: Path) -> None:
            if not f.is_file() or f.suffix != ".dart":
                return
            rel = f.relative_to(pres)
            if rel.parts[0] in ("pages", "widgets", "state", "music", "video"):
                # already in subfolder or music/video
                if rel.parts[0] in ("music", "video"):
                    return
                return
            bucket = classify_presentation(f, f.name)
            dst = pres / bucket / f.name
            if f != dst:
                shutil.move(str(f), str(dst))
                moves.append((str(f.relative_to(ROOT)), str(dst.relative_to(ROOT))))

        for f in list(pres.iterdir()):
            if f.is_dir() and f.name in ("music", "video"):
                for mf in f.iterdir():
                    if mf.is_file() and mf.suffix == ".dart":
                        bucket = classify_presentation(mf, mf.name)
                        dst = f / bucket / mf.name
                        (f / bucket).mkdir(parents=True, exist_ok=True)
                        if mf != dst:
                            shutil.move(str(mf), str(dst))
                            moves.append((str(mf.relative_to(ROOT)), str(dst.relative_to(ROOT))))
            else:
                move_pres_file(f)

    return moves


def migrate_core() -> list[tuple[str, str]]:
    moves: list[tuple[str, str]] = []

    storage = LIB / "core" / "storage"
    for sub, files in {
        "key_value": ["hos_local_storage.dart"],
        "secure": ["hos_secure_storage.dart"],
    }.items():
        d = storage / sub
        d.mkdir(parents=True, exist_ok=True)
        for fn in files:
            src = storage / fn
            if src.exists():
                dst = d / fn
                shutil.move(str(src), str(dst))
                moves.append((str(src.relative_to(ROOT)), str(dst.relative_to(ROOT))))

    img = storage / "hos_image_cache_manager.dart"
    if img.exists():
        cache = LIB / "core" / "cache"
        cache.mkdir(parents=True, exist_ok=True)
        dst = cache / "hos_image_cache_manager.dart"
        shutil.move(str(img), str(dst))
        moves.append((str(img.relative_to(ROOT)), str(dst.relative_to(ROOT))))

    net = LIB / "core" / "network"
    interceptors = net / "interceptors"
    interceptors.mkdir(parents=True, exist_ok=True)
    for fn in ["hos_auth_interceptor.dart", "hos_network_log_interceptor.dart"]:
        src = net / fn
        if src.exists():
            dst = interceptors / fn
            shutil.move(str(src), str(dst))
            moves.append((str(src.relative_to(ROOT)), str(dst.relative_to(ROOT))))

    conn = net / "hos_connectivity_service.dart"
    if conn.exists():
        dst = net / "hos_network_info.dart"
        shutil.move(str(conn), str(dst))
        moves.append((str(conn.relative_to(ROOT)), str(dst.relative_to(ROOT))))

    return moves


def build_import_replacements(moves: list[tuple[str, str]]) -> list[tuple[str, str]]:
    reps: list[tuple[str, str]] = []
    for old, new in moves:
        old_pkg = old.replace("lib/", "package:shoo/")
        new_pkg = new.replace("lib/", "package:shoo/")
        reps.append((old_pkg, new_pkg))
        # relative imports within features
        old_rel = old.replace("lib/", "")
        new_rel = new.replace("lib/", "")
        reps.append((old_rel, new_rel))
    # class renames in moved files
    reps.extend(
        [
            ("SHOAuthApi", "SHOAuthRemoteDataSource"),
            ("authApiProvider", "authRemoteDsProvider"),
            ("hos_auth_api.dart", "hos_auth_remote_ds.dart"),
            ("hos_connectivity_service.dart", "hos_network_info.dart"),
            ("SHOConnectivityService", "SHONetworkInfo"),
            ("connectivityServiceProvider", "networkInfoProvider"),
            ("core/storage/hos_local_storage.dart", "core/storage/key_value/hos_local_storage.dart"),
            ("core/storage/hos_secure_storage.dart", "core/storage/secure/hos_secure_storage.dart"),
            ("core/storage/hos_image_cache_manager.dart", "core/cache/hos_image_cache_manager.dart"),
            ("core/network/hos_auth_interceptor.dart", "core/network/interceptors/hos_auth_interceptor.dart"),
            (
                "core/network/hos_network_log_interceptor.dart",
                "core/network/interceptors/hos_network_log_interceptor.dart",
            ),
            (
                "features/auth/presentation/hos_session_provider.dart",
                "features/auth/presentation/state/hos_session_provider.dart",
            ),
            (
                "features/auth/presentation/hos_auth_token_provider.dart",
                "features/auth/presentation/state/hos_auth_token_provider.dart",
            ),
            (
                "features/home/presentation/hos_home_side_drawer.dart",
                "features/home/presentation/widgets/hos_home_side_drawer.dart",
            ),
            (
                "features/home/presentation/hos_home_page.dart",
                "features/home/presentation/pages/hos_home_page.dart",
            ),
        ]
    )
    return reps


def apply_import_updates(reps: list[tuple[str, str]]) -> None:
  for path in list(LIB.rglob("*.dart")) + list((ROOT / "test").rglob("*.dart")):
        text = path.read_text(encoding="utf-8")
        orig = text
        for old, new in reps:
            text = text.replace(old, new)
        if text != orig:
            path.write_text(text, encoding="utf-8")


def main() -> None:
    all_moves: list[tuple[str, str]] = []
    features = LIB / "features"
    for feat in sorted(features.iterdir()):
        if feat.is_dir():
            all_moves.extend(migrate_feature(feat))

    all_moves.extend(migrate_core())
    reps = build_import_replacements(all_moves)
    apply_import_updates(reps)
    print(f"Migrated {len(all_moves)} paths")


if __name__ == "__main__":
    main()
