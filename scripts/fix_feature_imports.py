#!/usr/bin/env python3
"""Resolve broken imports by path rewrite rules + filename index."""
from __future__ import annotations

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
TEST = ROOT / "test"


def pkg(path: Path) -> str:
    rel = path.relative_to(LIB).as_posix()
    return f"package:shoo/{rel}"


def build_index() -> dict[str, list[str]]:
    idx: dict[str, list[str]] = {}
    for p in LIB.rglob("*.dart"):
        idx.setdefault(p.name, []).append(pkg(p))
    return idx


RULES: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"features/(\w+)/domain/"), r"features/\1/domain/entities/"),
    (re.compile(r"features/(\w+)/data/hos_(\w+)_api\.dart"), r"features/\1/data/datasources/remote/hos_\2_remote_ds.dart"),
    (re.compile(r"features/(\w+)/data/hos_(\w+)_repository\.dart"), r"features/\1/data/repositories/hos_\2_repository_impl.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_session_provider\.dart"), r"features/auth/presentation/state/hos_session_provider.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_auth_token_provider\.dart"), r"features/auth/presentation/state/hos_auth_token_provider.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_home_page\.dart"), r"features/home/presentation/pages/hos_home_page.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_home_side_drawer\.dart"), r"features/home/presentation/widgets/hos_home_side_drawer.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_category_controller\.dart"), r"features/category/presentation/state/hos_category_controller.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_category_page\.dart"), r"features/category/presentation/pages/hos_category_page.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_cart_page\.dart"), r"features/cart/presentation/pages/hos_cart_page.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_cart_controller\.dart"), r"features/cart/presentation/state/hos_cart_controller.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_cart_badge_provider\.dart"), r"features/cart/presentation/state/hos_cart_badge_provider.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_sku_sheet\.dart"), r"features/cart/presentation/widgets/hos_sku_sheet.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_community_page\.dart"), r"features/community/presentation/pages/hos_community_page.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_message_page\.dart"), r"features/message/presentation/pages/hos_message_page.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_message_controller\.dart"), r"features/message/presentation/state/hos_message_controller.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_profile_page\.dart"), r"features/profile/presentation/pages/hos_profile_page.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_about_page\.dart"), r"features/profile/presentation/pages/hos_about_page.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_settings_page\.dart"), r"features/profile/presentation/pages/hos_settings_page.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_settings_cache_page\.dart"), r"features/profile/presentation/pages/hos_settings_cache_page.dart"),
    (re.compile(r"features/(\w+)/presentation/hos_reviews_page\.dart"), r"features/review/presentation/pages/hos_reviews_page.dart"),
    (re.compile(r"features/(\w+)/presentation/study_home_page\.dart"), r"features/study/presentation/pages/study_home_page.dart"),
    (re.compile(r"features/(\w+)/presentation/study_article_page\.dart"), r"features/study/presentation/pages/study_article_page.dart"),
    (re.compile(r"features/(\w+)/presentation/music/hos_music_nav_observer\.dart"), r"features/toolbox/presentation/music/state/hos_music_nav_observer.dart"),
    (re.compile(r"features/(\w+)/presentation/music/hos_music_route_state\.dart"), r"features/toolbox/presentation/music/state/hos_music_route_state.dart"),
    (re.compile(r"features/(\w+)/presentation/music/hos_music_mini_player\.dart"), r"features/toolbox/presentation/music/widgets/hos_music_mini_player.dart"),
    (re.compile(r"features/(\w+)/data/hos_cart_storage\.dart"), r"features/cart/data/datasources/local/hos_cart_storage.dart"),
    (re.compile(r"features/(\w+)/data/hos_search_history_storage\.dart"), r"features/search/data/datasources/local/hos_search_history_storage.dart"),
    (re.compile(r"features/(\w+)/data/hos_reading_storage_keys\.dart"), r"features/toolbox/data/datasources/local/hos_reading_storage_keys.dart"),
    (re.compile(r"features/(\w+)/data/hos_music_storage_keys\.dart"), r"features/toolbox/data/datasources/local/hos_music_storage_keys.dart"),
    (re.compile(r"features/(\w+)/data/hos_video_storage_keys\.dart"), r"features/toolbox/data/datasources/local/hos_video_storage_keys.dart"),
    (re.compile(r"features/(\w+)/data/hos_(\w+)_storage\.dart"), r"features/\1/data/datasources/local/hos_\2_storage.dart"),
    (re.compile(r"features/(\w+)/data/hos_(\w+)_service\.dart"), r"features/\1/data/repositories/hos_\2_service_impl.dart"),
    (re.compile(r"features/(\w+)/data/hos_download_paths\.dart"), r"features/toolbox/data/datasources/local/hos_download_paths.dart"),
    (re.compile(r"features/(\w+)/data/hos_music_catalog\.dart"), r"features/toolbox/data/datasources/remote/hos_music_catalog.dart"),
    (re.compile(r"features/(\w+)/data/hos_(\w+)\.dart"), r"features/toolbox/data/datasources/remote/hos_\2.dart"),  # risky last
]


def normalize_import(imp: str) -> str:
    s = imp
    if s.startswith("package:shoo/"):
        s = s[len("package:shoo/") :]
    s = re.sub(r"^(\.\./)+", "", s)
    for pat, repl in RULES:
        s2 = pat.sub(repl, s)
        if s2 != s:
            s = s2
            break
    return f"package:shoo/{s}"


def resolve_by_name(name: str, idx: dict[str, list[str]], hint: str) -> str | None:
    cands = idx.get(name, [])
    if not cands:
        return None
    if len(cands) == 1:
        return cands[0]
    # prefer hint path segment
    for c in cands:
        if hint and hint.replace("../", "") in c:
            return c
    for c in cands:
        if "/presentation/state/" in c or "/presentation/pages/" in c:
            if name.endswith("_controller.dart") or name.endswith("_provider.dart"):
                if "/state/" in c:
                    return c
            if name.endswith("_page.dart") and "/pages/" in c:
                return c
    return cands[0]


def fix_file(path: Path, idx: dict[str, list[str]]) -> bool:
    text = path.read_text(encoding="utf-8")
    orig = text

    def repl(m: re.Match[str]) -> str:
        imp = m.group(1)
        if imp.startswith("dart:") or imp.startswith("flutter/") or imp.startswith("package:flutter"):
            return m.group(0)
        # already valid package path
        if imp.startswith("package:shoo/"):
            target = imp
        else:
            target = normalize_import(imp)
        name = Path(imp.split("/")[-1]).name
        rel = (LIB / target.replace("package:shoo/", ""))
        if not rel.exists():
            alt = resolve_by_name(name, idx, imp)
            if alt:
                target = alt
        return f"import '{target}'"

    text = re.sub(r"import '([^']+)'", repl, text)
    if text != orig:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    idx = build_index()
    n = 0
    for root in (LIB, TEST):
        if not root.exists():
            continue
        for p in root.rglob("*.dart"):
            if fix_file(p, idx):
                n += 1
    print(f"fixed {n} files")
    r = subprocess.run(["dart", "analyze", "lib", "test"], cwd=ROOT, capture_output=True, text=True)
    errors = [ln for ln in r.stdout.splitlines() if ln.strip().startswith("error -")]
    print(f"errors: {len(errors)}")
    for ln in errors[:15]:
        print(ln)


if __name__ == "__main__":
    main()
