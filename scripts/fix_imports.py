#!/usr/bin/env python3
"""Fix imports after framework migration (per-file, feature-aware)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
TEST = ROOT / "test"

GLOBAL = [
    ("package:shoo/core/storage/hos_local_storage.dart", "package:shoo/core/storage/key_value/hos_local_storage.dart"),
    ("package:shoo/core/storage/hos_secure_storage.dart", "package:shoo/core/storage/secure/hos_secure_storage.dart"),
    ("package:shoo/core/storage/hos_image_cache_manager.dart", "package:shoo/core/cache/hos_image_cache_manager.dart"),
    ("package:shoo/core/network/hos_connectivity_service.dart", "package:shoo/core/network/hos_network_info.dart"),
    ("package:shoo/core/network/hos_auth_interceptor.dart", "package:shoo/core/network/interceptors/hos_auth_interceptor.dart"),
    ("package:shoo/core/network/hos_network_log_interceptor.dart", "package:shoo/core/network/interceptors/hos_network_log_interceptor.dart"),
    ("../storage/hos_local_storage.dart", "package:shoo/core/storage/key_value/hos_local_storage.dart"),
    ("../../storage/hos_local_storage.dart", "package:shoo/core/storage/key_value/hos_local_storage.dart"),
    ("../../../storage/hos_local_storage.dart", "package:shoo/core/storage/key_value/hos_local_storage.dart"),
    ("../storage/hos_secure_storage.dart", "package:shoo/core/storage/secure/hos_secure_storage.dart"),
    ("../../storage/hos_secure_storage.dart", "package:shoo/core/storage/secure/hos_secure_storage.dart"),
    ("../storage/hos_image_cache_manager.dart", "package:shoo/core/cache/hos_image_cache_manager.dart"),
    ("../../storage/hos_image_cache_manager.dart", "package:shoo/core/cache/hos_image_cache_manager.dart"),
    ("'hos_auth_interceptor.dart'", "'interceptors/hos_auth_interceptor.dart'"),
    ("'hos_network_log_interceptor.dart'", "'interceptors/hos_network_log_interceptor.dart'"),
    ("hos_connectivity_service.dart", "hos_network_info.dart"),
    ("SHOConnectivityService", "SHONetworkInfo"),
    ("connectivityServiceProvider", "networkInfoProvider"),
]


def feature_for(path: Path) -> str | None:
    parts = path.parts
    if "features" not in parts:
        return None
    i = parts.index("features")
    if i + 1 < len(parts):
        return parts[i + 1]
    return None


def fix_feature_imports(text: str, feat: str) -> str:
    base = f"package:shoo/features/{feat}"
    reps = [
        (rf"import '\.\./domain/([^']+)'", rf"import '{base}/domain/entities/\1'"),
        (rf"import '\.\./\.\./domain/([^']+)'", rf"import '{base}/domain/entities/\1'"),
        (rf"import '\.\./\.\./\.\./domain/([^']+)'", rf"import '{base}/domain/entities/\1'"),
        (rf"import '\.\./data/([^']+)'", rf"import '{base}/data/\1'"),
        (rf"import '\.\./\.\./data/([^']+)'", rf"import '{base}/data/\1'"),
        (rf"import '\.\./presentation/([^']+)'", rf"import '{base}/presentation/\1'"),
        (rf"import '\.\./\.\./presentation/([^']+)'", rf"import '{base}/presentation/\1'"),
        (rf"import '\.\./\.\./\.\./presentation/([^']+)'", rf"import '{base}/presentation/\1'"),
        (f"hos_{feat}_api.dart", f"hos_{feat}_remote_ds.dart"),
        (f"hos_{feat}_repository.dart", f"hos_{feat}_repository_impl.dart"),
    ]
    for old, new in reps:
        if old.startswith("import"):
            text = re.sub(old, new, text)
        else:
            text = text.replace(old, new)
    return text


def fix_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    orig = text
    for old, new in GLOBAL:
        text = text.replace(old, new)

    feat = feature_for(path)
    if feat:
        text = fix_feature_imports(text, feat)

    if "core/storage/key_value" in str(path) or "core/storage/secure" in str(path):
        text = text.replace("import '../constants/", "import 'package:shoo/core/constants/")
        text = text.replace("import '../errors/", "import 'package:shoo/core/errors/")
        text = text.replace(
            "import '../../features/toolbox/data/datasources/local/",
            "import 'package:shoo/features/toolbox/data/datasources/local/",
        )

    if "core/network/interceptors" in str(path):
        text = text.replace("import '../debug/", "import 'package:shoo/core/debug/")
        text = text.replace("import '../logging/", "import 'package:shoo/core/logging/")

    if "core/cache/hos_image_cache_manager.dart" in str(path):
        text = text.replace("import '../config/", "import 'package:shoo/core/config/")
        text = text.replace("import '../logging/", "import 'package:shoo/core/logging/")
        text = text.replace("import '../errors/", "import 'package:shoo/core/errors/")

    text = re.sub(r"import '\.\./\.\./\.\./core/", "import 'package:shoo/core/", text)
    text = re.sub(r"import '\.\./\.\./\.\./\.\./core/", "import 'package:shoo/core/", text)
    text = re.sub(r"import '\.\./\.\./\.\./\.\./\.\./core/", "import 'package:shoo/core/", text)

    # cross-feature presentation paths (app, core referencing features)
    cross = [
        (
            "features/auth/presentation/hos_session_provider.dart",
            "features/auth/presentation/state/hos_session_provider.dart",
        ),
        (
            "features/auth/presentation/hos_auth_token_provider.dart",
            "features/auth/presentation/state/hos_auth_token_provider.dart",
        ),
        (
            "features/home/presentation/hos_home_page.dart",
            "features/home/presentation/pages/hos_home_page.dart",
        ),
        (
            "features/home/presentation/hos_home_side_drawer.dart",
            "features/home/presentation/widgets/hos_home_side_drawer.dart",
        ),
        (
            "features/category/presentation/hos_category_controller.dart",
            "features/category/presentation/state/hos_category_controller.dart",
        ),
    ]
    for old, new in cross:
        text = text.replace(old, new)

    if text != orig:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    n = 0
    for root in (LIB, TEST):
        for p in root.rglob("*.dart"):
            if fix_file(p):
                n += 1
    print(f"fixed {n} files")


if __name__ == "__main__":
    main()
