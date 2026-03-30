#!/usr/bin/env python3
"""
Generates Batch 3 targets: stations/assets/plists,
patches project.pbxproj, writes xcschemes.

Usage:
  python3 lang-apps/tools/generate_batch3_targets.py
  python3 lang-apps/tools/generate_batch3_targets.py --appicons-only   # copy AppIcon from Batch 3 only
"""
from __future__ import annotations

import csv
import hashlib
import json
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LANG_APPS = ROOT / "lang-apps"
PBX = ROOT / "lang-apps.xcodeproj" / "project.pbxproj"
SCHEMES_DIR = ROOT / "lang-apps.xcodeproj" / "xcshareddata" / "xcschemes"
CSV_PATH = Path.home() / "Downloads" / "Atech Consultancy Ltd_2026-03-30.csv"
BATCH3 = Path.home() / "Downloads" / "Batch 3 Apps"
SWAHILI_ASSETS = LANG_APPS / "Targets" / "Swahili" / "swahiliAssets.xcassets"
SWAHILI_PLIST = LANG_APPS / "Targets" / "Swahili" / "swahili.plist"

STORE_ID_RE = re.compile(r"/id(\d+)\?")

LEGACY_NATIVE = {
    "cantonese": "672CDB092F5C49EE0057E983",
    "swahili": "672CDB722F5C4DB00057E983",
    "haitian": "672CDC142F5C4FC50057E983",
    "khmer": "672CDC7F2F5C507F0057E983",
    "lang-apps": "6794579E2F3B9F80007DC1F5",
}
LEGACY_EXC = {
    "cantonese": "672CDB1A2F5C49EE0057E983",
    "swahili": "672CDB832F5C4DB00057E983",
    "haitian": "672CDC252F5C4FC50057E983",
    "khmer": "672CDC902F5C507F0057E983",
    "lang-apps": "679457B12F3B9F81007DC1F5",
}


def oid(s: str) -> str:
    return hashlib.md5(s.encode("utf-8")).hexdigest()[:24].upper()


def xcode_folder(batch_name: str) -> str:
    return re.sub(r"[^a-zA-Z0-9]", "", batch_name)


def file_prefix(folder: str) -> str:
    if not folder:
        return ""
    return folder[0].lower() + folder[1:]


def display_name(csv_name: str) -> str:
    for p in ("Fast - Speak ", "Fast - Learn "):
        if csv_name.startswith(p):
            rest = csv_name[len(p) :]
            rest = re.sub(r"\s+Language\s*$", "", rest, flags=re.I)
            return "Learn " + rest
    return csv_name


def load_csv_rows() -> dict[str, dict]:
    out: dict[str, dict] = {}
    with open(CSV_PATH, newline="", encoding="utf-8") as f:
        r = csv.DictReader(f)
        for row in r:
            name = row["Name"].strip().strip('"')
            bid = row["Bundle ID"].strip()
            url = row.get("App Store URL") or ""
            m = STORE_ID_RE.search(url)
            aid = m.group(1) if m else ""
            ver = (row.get("Version") or "3.0.0").strip()
            out[name] = {"bundle": bid, "apple_id": aid, "version": ver}
    return out


CSV_NAMES_ORDERED = [
    "Fast - Speak Azerbaijani",
    "Fast - Speak Bambara Language",
    "Fast - Learn Bislama Language",
    "Fast - Learn Cameroon Language",
    "Fast - Learn Chewa Language",
    "Fast - Learn Chinese Language",
    "Fast - Learn Chinyanja",
    "Fast - Learn Egyptian Arabic",
    "Fast - Speak Ewe Language",
    "Fast - Learn French Mali",
    "Fast - Learn Fula Language",
    "Fast - Speak Hausa Language",
    "Fast - Learn Hijazi Dialect",
    "Fast - Speak Igbo Language",
    "Fast - Learn Iraqi Language",
    "Fast - Speak Jahanka Language",
    "Fast - Speak Jola Language",
    "Fast - Learn Jordanian",
    "Fast - Speak Kirundi Language",
    "Fast - Speak Kituba Language",
    "Fast - Speak Krio Language",
    "Fast - Speak Lao Language",
    "Fast - Speak Levantine",
    "Fast - Speak Lingala Language",
    "Fast - Speak Luganda Language",
    "Fast - Speak Madinka Language",
    "Fast - Speak Malagasy Language",
    "Fast - Learn Mauritanian",
    "Fast - Speak Moldovan Language",
    "Fast - Speak Mongolian",
    "Fast - Learn Moore Language",
    "Fast - Speak Moroccan Language",
    "Fast - Speak More (Mossi)",
    "Fast - Speak Nepali Language",
    "Fast - Speak Pulaar Language",
    "Fast - Speak Samoan Language",
    "Fast - Speak Sarahulle",
    "Fast - Speak Setswana Language",
    "Fast - Speak Shona Language",
    "Fast - Speak Soninke Language",
    "Fast - Speak Sranan Language",
    "Fast - Learn Syrian Language",
    "Fast - Learn Twi Language",
    "Fast - Speak Wolof Language",
    "Fast - Speak Yoruba Language",
    "Fast - Speak Zarma Language",
]


def batch_folder_for_csv_name(csv_name: str) -> str:
    rest = csv_name
    for p in ("Fast - Speak ", "Fast - Learn "):
        if rest.startswith(p):
            rest = rest[len(p) :]
    if rest.endswith(" Language"):
        rest = rest[: -len(" Language")]
    special = {
        "Egyptian Arabic": "Egyptian",
        "French Mali": "French Mali",
        "Hijazi Dialect": "Hijazi",
        "Iraqi": "Iraqi",
        "Jordanian": "Jordanian",
        "Mauritanian": "Mauritanian",
        "More (Mossi)": "More (Mossi)",
        "Syrian": "Syrian",
        "Twi": "Twi",
    }
    if rest in special:
        return special[rest]
    return rest


def copy_appicon_from_batch3(batch_folder: str, dest_assets_xcassets: Path) -> None:
    """Replace ``AppIcon.appiconset`` under *dest_assets_xcassets* with Batch 3 SwiftRadio icons."""
    base = BATCH3 / batch_folder
    preferred = base / "SwiftRadio" / "Images.xcassets" / "AppIcon.appiconset"
    if preferred.is_dir():
        src = preferred
    else:
        found = [p for p in base.rglob("AppIcon.appiconset") if p.is_dir()]
        if not found:
            print(f"Warning: no AppIcon.appiconset in Batch 3 for {batch_folder}", file=sys.stderr)
            return
        src = found[0]
    dest = dest_assets_xcassets / "AppIcon.appiconset"
    if dest.is_dir():
        shutil.rmtree(dest)
    shutil.copytree(src, dest)


def sync_all_batch3_appicons() -> int:
    if not BATCH3.is_dir():
        print("Missing Batch 3 folder:", BATCH3, file=sys.stderr)
        return 1
    for csv_name in CSV_NAMES_ORDERED:
        batch = batch_folder_for_csv_name(csv_name)
        folder = xcode_folder(batch)
        fp = file_prefix(folder)
        dest_assets = LANG_APPS / "Targets" / folder / f"{fp}Assets.xcassets"
        if not dest_assets.is_dir():
            print("Skip (no assets dir):", dest_assets, file=sys.stderr)
            continue
        copy_appicon_from_batch3(batch, dest_assets)
        print("AppIcon:", folder)
    return 0


def process_stations(src_json: Path, dest: Path, long_desc: str) -> None:
    data = json.loads(src_json.read_text(encoding="utf-8"))
    for st in data.get("station", []):
        if not (st.get("longDesc") or "").strip():
            st["longDesc"] = long_desc
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def rewrite_station_urls_webron(stations_path: Path, webron_id: int) -> None:
    """Non–Google-Drive URLs → webron host; path uses content id (table rows 57–102), not App Store id."""
    from urllib.parse import urlparse

    data = json.loads(stations_path.read_text(encoding="utf-8"))
    changed = False
    for st in data.get("station", []):
        u = st.get("streamURL") or ""
        if not u or "drive.google.com" in u:
            continue
        if "lentil.webron.software" in u:
            new_u = re.sub(
                r"(https://lentil\.webron\.software/)\d+/",
                rf"\g<1>{webron_id}/",
                u,
            )
            if new_u != u:
                st["streamURL"] = new_u
                changed = True
            continue
        path = urlparse(u).path
        fname = path.rstrip("/").split("/")[-1] if path else ""
        if not fname:
            safe = re.sub(r"[^a-zA-Z0-9._-]+", "_", st.get("name", "lesson"))
            fname = f"{safe}.mp3"
        enc = fname.replace(" ", "%20")
        st["streamURL"] = f"https://lentil.webron.software/{webron_id}/{enc}"
        changed = True
    if changed:
        stations_path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )


def exc_id(tn: str) -> str:
    return LEGACY_EXC.get(tn) or oid(f"exc-{tn}")


def nt_id(tn: str) -> str:
    return LEGACY_NATIVE.get(tn) or oid(f"native-{tn}")


def write_scheme(tn: str, nt: str) -> None:
    SCHEMES_DIR.mkdir(parents=True, exist_ok=True)
    xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "2600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES"
      buildArchitectures = "Automatic">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{nt}"
               BuildableName = "{tn}.app"
               BlueprintName = "{tn}"
               ReferencedContainer = "container:lang-apps.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{nt}"
            BuildableName = "{tn}.app"
            BlueprintName = "{tn}"
            ReferencedContainer = "container:lang-apps.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{nt}"
            BuildableName = "{tn}.app"
            BlueprintName = "{tn}"
            ReferencedContainer = "container:lang-apps.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""
    (SCHEMES_DIR / f"{tn}.xcscheme").write_text(xml, encoding="utf-8")


def main() -> int:
    force_pbx = "--force-pbx" in sys.argv
    if not CSV_PATH.is_file():
        print("Missing CSV:", CSV_PATH, file=sys.stderr)
        return 1
    if not BATCH3.is_dir():
        print("Missing Batch 3 folder:", BATCH3, file=sys.stderr)
        return 1

    csv_data = load_csv_rows()
    targets: list[dict] = []

    legacy_xcode = [
        ("cantonese", "Cantonese", "cantonese"),
        ("swahili", "Swahili", "swahili"),
        ("haitian", "Haitian", "haitian"),
        ("khmer", "Khmer", "khmer"),
    ]

    for idx, csv_name in enumerate(CSV_NAMES_ORDERED):
        if csv_name not in csv_data:
            print("CSV missing:", csv_name, file=sys.stderr)
            return 1
        row = csv_data[csv_name]
        bundle = row["bundle"]
        apple_id = row["apple_id"]
        webron_id = 57 + idx  # spreadsheet row ids 57…102, not App Store ids
        if not apple_id:
            print("No App Store id for:", csv_name, file=sys.stderr)
            return 1
        batch = batch_folder_for_csv_name(csv_name)
        bpath = BATCH3 / batch / "SwiftRadio" / "stations.json"
        if not bpath.is_file():
            alt = list((BATCH3 / batch).rglob("stations.json"))
            if alt:
                bpath = alt[0]
            else:
                print("No stations.json for:", batch, file=sys.stderr)
                return 1

        folder = xcode_folder(batch)
        fp = file_prefix(folder)
        tname = fp
        disp = display_name(csv_name)
        ver = row["version"]

        tdir = LANG_APPS / "Targets" / folder
        dest_assets = tdir / f"{fp}Assets.xcassets"
        if dest_assets.is_dir():
            shutil.rmtree(dest_assets)
        shutil.copytree(SWAHILI_ASSETS, dest_assets)
        copy_appicon_from_batch3(batch, dest_assets)
        shutil.copy2(SWAHILI_PLIST, tdir / f"{fp}.plist")

        dest_stations = tdir / "stations.json"
        process_stations(bpath, dest_stations, csv_name)
        rewrite_station_urls_webron(dest_stations, webron_id)

        ui_style = "Light" if (int(hashlib.md5(tname.encode()).hexdigest(), 16) % 2) == 0 else "Dark"

        targets.append(
            {
                "target_name": tname,
                "folder": folder,
                "file_prefix": fp,
                "bundle": bundle,
                "display": disp,
                "version": ver,
                "ui_style": ui_style,
            }
        )

    if PBX.read_text(encoding="utf-8").find("azerbaijani.app") != -1 and not force_pbx:
        print(
            "Batch 3 asset folders updated. Skipping pbxproj (already contains batch3). "
            "Pass --force-pbx to regenerate project file. "
            "Update TargetManager.swift when adding new bundle IDs.",
        )
        return 0

    all_td = legacy_xcode + [(t["target_name"], t["folder"], t["file_prefix"]) for t in targets]

    def exceptions_for(own: tuple[str, str, str]) -> str:
        lines = ["\t\t\t\tInfo.plist,"]
        for tn, fd, pr in all_td:
            if (tn, fd, pr) == own:
                continue
            lines.append(f"\t\t\t\tTargets/{fd}/{pr}Assets.xcassets,")
            lines.append(f"\t\t\t\tTargets/{fd}/stations.json,")
        lines[-1] = lines[-1].rstrip(",")
        return "\n".join(lines)

    exc_section_lines = []
    # lang-apps first
    lang_lines = ["\t\t\t\tInfo.plist,"]
    for tn, fd, pr in all_td:
        lang_lines.append(f"\t\t\t\tTargets/{fd}/{pr}Assets.xcassets,")
        lang_lines.append(f"\t\t\t\tTargets/{fd}/stations.json,")
    lang_lines[-1] = lang_lines[-1].rstrip(",")
    exc_section_lines.append(
        f"\t\t{exc_id('lang-apps')} /* Exceptions for \"lang-apps\" folder in \"lang-apps\" target */ = {{\n"
        f"\t\t\tisa = PBXFileSystemSynchronizedBuildFileExceptionSet;\n"
        f"\t\t\tmembershipExceptions = (\n"
        f"{chr(10).join(lang_lines)}\n"
        f"\t\t\t);\n"
        f"\t\t\ttarget = {nt_id('lang-apps')} /* lang-apps */;\n"
        f"\t\t}};"
    )
    for tn, fd, pr in all_td:
        exc_section_lines.append(
            f"\t\t{exc_id(tn)} /* Exceptions for \"lang-apps\" folder in \"{tn}\" target */ = {{\n"
            f"\t\t\tisa = PBXFileSystemSynchronizedBuildFileExceptionSet;\n"
            f"\t\t\tmembershipExceptions = (\n"
            f"{exceptions_for((tn, fd, pr))}\n"
            f"\t\t\t);\n"
            f"\t\t\ttarget = {nt_id(tn)} /* {tn} */;\n"
            f"\t\t}};"
        )

    new_exc = (
        "/* Begin PBXFileSystemSynchronizedBuildFileExceptionSet section */\n"
        + "\n".join(exc_section_lines)
        + "\n/* End PBXFileSystemSynchronizedBuildFileExceptionSet section */"
    )

    pbx = PBX.read_text(encoding="utf-8")
    pbx = re.sub(
        r"/\* Begin PBXFileSystemSynchronizedBuildFileExceptionSet section \*/.*?/\* End PBXFileSystemSynchronizedBuildFileExceptionSet section \*/",
        new_exc,
        pbx,
        count=1,
        flags=re.DOTALL,
    )

    # exceptions = ( ... ) inside PBXFileSystemSynchronizedRootGroup
    labels = ["lang-apps", "cantonese", "swahili", "haitian", "khmer"] + [t["target_name"] for t in targets]
    exc_list = "\n".join(
        f"\t\t\t\t{exc_id(lb)} /* Exceptions for \"lang-apps\" folder in \"{lb}\" target */,"
        for lb in labels
    )
    pbx = re.sub(
        r"(679457A12F3B9F80007DC1F5 /\* lang-apps \*/ = \{\n\t\t\tisa = PBXFileSystemSynchronizedRootGroup;\n\t\t\t)exceptions = \(\n(?:\t\t\t\t[^\n]+\n)+\t\t\t\);",
        r"\1exceptions = (\n" + exc_list + "\n\t\t\t);",
        pbx,
        count=1,
    )

    # Remove OTHER_SWIFT_FLAGS from legacy 4 language targets only
    for flag in ("-DYUE", "-DSW", "-DHT", "-DKM"):
        pbx = pbx.replace(f'\t\t\t\tOTHER_SWIFT_FLAGS = "{flag}";\n', "")

    # --- New targets: file refs, build files, native targets, phases, configs, packages ---
    file_refs: list[str] = []
    build_files: list[str] = []
    native_targets: list[str] = []
    fw_phases: list[str] = []
    src_phases: list[str] = []
    res_phases: list[str] = []
    build_cfgs: list[str] = []
    cfg_lists: list[str] = []
    pkg_refs: list[str] = []
    pkg_deps: list[str] = []
    product_children: list[str] = []
    target_names_order: list[str] = []

    for t in targets:
        tn = t["target_name"]
        fp = t["file_prefix"]
        folder = t["folder"]
        bundle = t["bundle"]
        disp = t["display"].replace('"', '\\"')
        ver = t["version"]
        ui = t["ui_style"]

        n_nt = nt_id(tn)
        app_ref = oid(f"appref-{tn}")
        src = oid(f"src-{tn}")
        fw = oid(f"fw-{tn}")
        res = oid(f"res-{tn}")
        bcl = oid(f"bcl-{tn}")
        bcd = oid(f"bcd-{tn}")
        bcr = oid(f"bcr-{tn}")
        pkg_uir = oid(f"pkg-uir-{tn}")
        pkg_gma = oid(f"pkg-gma-{tn}")
        pkg_rc = oid(f"pkg-rc-{tn}")
        dep_uir = oid(f"dep-uir-{tn}")
        dep_gma = oid(f"dep-gma-{tn}")
        dep_rc = oid(f"dep-rc-{tn}")
        bf_gma = oid(f"bf-gma-{tn}")
        bf_uir = oid(f"bf-uir-{tn}")
        bf_rc = oid(f"bf-rc-{tn}")

        product_children.append(f"\t\t\t\t{app_ref} /* {tn}.app */,")
        target_names_order.append(f"\t\t\t\t{n_nt} /* {tn} */,")

        file_refs.append(
            f"\t\t{app_ref} /* {tn}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {tn}.app; sourceTree = BUILT_PRODUCTS_DIR; }};"
        )
        build_files += [
            f"\t\t{bf_gma} /* GoogleMobileAds in Frameworks */ = {{isa = PBXBuildFile; productRef = {dep_gma} /* GoogleMobileAds */; }};",
            f"\t\t{bf_uir} /* UICircularProgressRing in Frameworks */ = {{isa = PBXBuildFile; productRef = {dep_uir} /* UICircularProgressRing */; }};",
            f"\t\t{bf_rc} /* RevenueCat in Frameworks */ = {{isa = PBXBuildFile; productRef = {dep_rc} /* RevenueCat */; }};",
        ]

        native_targets.append(
            f"""\t\t{n_nt} /* {tn} */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {bcl} /* Build configuration list for PBXNativeTarget "{tn}" */;
			buildPhases = (
				{src} /* Sources */,
				{fw} /* Frameworks */,
				{res} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			fileSystemSynchronizedGroups = (
				679457A12F3B9F80007DC1F5 /* lang-apps */,
			);
			name = {tn};
			packageProductDependencies = (
				{dep_uir} /* UICircularProgressRing */,
				{dep_gma} /* GoogleMobileAds */,
				{dep_rc} /* RevenueCat */,
			);
			productName = "lang-apps";
			productReference = {app_ref} /* {tn}.app */;
			productType = "com.apple.product-type.application";
		}};"""
        )

        fw_phases.append(
            f"""\t\t{fw} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{bf_gma} /* GoogleMobileAds in Frameworks */,
				{bf_uir} /* UICircularProgressRing in Frameworks */,
				{bf_rc} /* RevenueCat in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
        )
        src_phases.append(
            f"""\t\t{src} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
        )
        res_phases.append(
            f"""\t\t{res} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
        )

        plist_path = f"lang-apps/Targets/{folder}/{fp}.plist"
        build_cfgs += [
            f"""\t\t{bcd} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = "{plist_path}";
				INFOPLIST_KEY_CFBundleDisplayName = "{disp}";
				INFOPLIST_KEY_NSUserTrackingUsageDescription = "We use your data to deliver more relevant ads and keep the app free.";
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchStoryboardName = LaunchScreen;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UIUserInterfaceStyle = {ui};
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = {ver};
				PRODUCT_BUNDLE_IDENTIFIER = {bundle};
				PRODUCT_NAME = "$(TARGET_NAME)";
				STRING_CATALOG_GENERATE_SYMBOLS = YES;
				SWIFT_APPROACHABLE_CONCURRENCY = YES;
				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};""",
            f"""\t\t{bcr} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = "{plist_path}";
				INFOPLIST_KEY_CFBundleDisplayName = "{disp}";
				INFOPLIST_KEY_NSUserTrackingUsageDescription = "We use your data to deliver more relevant ads and keep the app free.";
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchStoryboardName = LaunchScreen;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UIUserInterfaceStyle = {ui};
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = {ver};
				PRODUCT_BUNDLE_IDENTIFIER = {bundle};
				PRODUCT_NAME = "$(TARGET_NAME)";
				STRING_CATALOG_GENERATE_SYMBOLS = YES;
				SWIFT_APPROACHABLE_CONCURRENCY = YES;
				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};""",
        ]

        cfg_lists.append(
            f"""\t\t{bcl} /* Build configuration list for PBXNativeTarget "{tn}" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{bcd} /* Debug */,
				{bcr} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};"""
        )

        pkg_refs += [
            f"""\t\t{pkg_uir} /* XCRemoteSwiftPackageReference "UICircularProgressRing" */ = {{
			isa = XCRemoteSwiftPackageReference;
			repositoryURL = "https://github.com/o16i/UICircularProgressRing.git";
			requirement = {{
				branch = master;
				kind = branch;
			}};
		}};""",
            f"""\t\t{pkg_gma} /* XCRemoteSwiftPackageReference "swift-package-manager-google-mobile-ads" */ = {{
			isa = XCRemoteSwiftPackageReference;
			repositoryURL = "https://github.com/googleads/swift-package-manager-google-mobile-ads";
			requirement = {{
				kind = upToNextMajorVersion;
				minimumVersion = 13.0.0;
			}};
		}};""",
            f"""\t\t{pkg_rc} /* XCRemoteSwiftPackageReference "purchases-ios-spm" */ = {{
			isa = XCRemoteSwiftPackageReference;
			repositoryURL = "https://github.com/RevenueCat/purchases-ios-spm";
			requirement = {{
				kind = upToNextMajorVersion;
				minimumVersion = 5.59.2;
			}};
		}};""",
        ]
        pkg_deps += [
            f'\t\t{dep_uir} /* UICircularProgressRing */ = {{\n\t\t\tisa = XCSwiftPackageProductDependency;\n\t\t\tpackage = {pkg_uir} /* XCRemoteSwiftPackageReference "UICircularProgressRing" */;\n\t\t\tproductName = UICircularProgressRing;\n\t\t}};',
            f'\t\t{dep_gma} /* GoogleMobileAds */ = {{\n\t\t\tisa = XCSwiftPackageProductDependency;\n\t\t\tpackage = {pkg_gma} /* XCRemoteSwiftPackageReference "swift-package-manager-google-mobile-ads" */;\n\t\t\tproductName = GoogleMobileAds;\n\t\t}};',
            f'\t\t{dep_rc} /* RevenueCat */ = {{\n\t\t\tisa = XCSwiftPackageProductDependency;\n\t\t\tpackage = {pkg_rc} /* XCRemoteSwiftPackageReference "purchases-ios-spm" */;\n\t\t\tproductName = RevenueCat;\n\t\t}};',
        ]

    # Insert build files after Begin PBXBuildFile
    pbx = pbx.replace(
        "/* Begin PBXBuildFile section */",
        "/* Begin PBXBuildFile section */\n" + "\n".join(build_files),
        1,
    )
    # Insert file refs before End PBXFileReference
    pbx = pbx.replace(
        "/* End PBXFileReference section */",
        "\n".join(file_refs) + "\n/* End PBXFileReference section */",
        1,
    )
    # Products group
    pbx = pbx.replace(
        "\t\t\t\t672CDC8F2F5C507F0057E983 /* khmer.app */,",
        "\t\t\t\t672CDC8F2F5C507F0057E983 /* khmer.app */,\n" + "\n".join(product_children),
        1,
    )
    # PBXNativeTarget section — before End
    pbx = pbx.replace(
        "/* End PBXNativeTarget section */",
        "\n".join(native_targets) + "\n/* End PBXNativeTarget section */",
        1,
    )
    # Frameworks build phases
    pbx = pbx.replace(
        "/* End PBXFrameworksBuildPhase section */",
        "\n".join(fw_phases) + "\n/* End PBXFrameworksBuildPhase section */",
        1,
    )
    pbx = pbx.replace(
        "/* End PBXSourcesBuildPhase section */",
        "\n".join(src_phases) + "\n/* End PBXSourcesBuildPhase section */",
        1,
    )
    pbx = pbx.replace(
        "/* End PBXResourcesBuildPhase section */",
        "\n".join(res_phases) + "\n/* End PBXResourcesBuildPhase section */",
        1,
    )
    pbx = pbx.replace(
        "/* End XCBuildConfiguration section */",
        "\n".join(build_cfgs) + "\n/* End XCBuildConfiguration section */",
        1,
    )
    pbx = pbx.replace(
        "/* End XCConfigurationList section */",
        "\n".join(cfg_lists) + "\n/* End XCConfigurationList section */",
        1,
    )
    pbx = pbx.replace(
        "/* End XCRemoteSwiftPackageReference section */",
        "\n".join(pkg_refs) + "\n/* End XCRemoteSwiftPackageReference section */",
        1,
    )
    pbx = pbx.replace(
        "/* End XCSwiftPackageProductDependency section */",
        "\n".join(pkg_deps) + "\n/* End XCSwiftPackageProductDependency section */",
        1,
    )

    # PBXProject targets = (
    pbx = pbx.replace(
        "\t\t\t\t672CDC7F2F5C507F0057E983 /* khmer */,\n\t\t\t);",
        "\t\t\t\t672CDC7F2F5C507F0057E983 /* khmer */,\n"
        + "\n".join(target_names_order)
        + "\n\t\t\t);",
        1,
    )

    PBX.write_text(pbx, encoding="utf-8")

    for t in targets:
        write_scheme(t["target_name"], nt_id(t["target_name"]))

    print("Done. Targets:", len(targets), "Registry + pbxproj + schemes updated.")
    return 0


if __name__ == "__main__":
    if "--appicons-only" in sys.argv:
        raise SystemExit(sync_all_batch3_appicons())
    raise SystemExit(main())
