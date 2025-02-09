config = {
    'base_name': 'Android armv7 api-16+ %(branch)s Gradle',
    'stage_platform': 'android-api-16-gradle',
    'build_type': 'api-16-gradle',
    'src_mozconfig': 'mobile/android/config/mozconfigs/android-api-16-gradle/nightly',
    'multi_locale_config_platform': 'android',
    # It's not obvious, but postflight_build is after packaging, so the Gecko
    # binaries are in the object directory, ready to be packaged into the
    # GeckoView AAR.
    'postflight_build_mach_commands': [
        ['gradle',
         'geckoview:assembleWithGeckoBinaries',
         'geckoview_example:assembleWithGeckoBinaries',
         'uploadArchives',
        ],
    ],
    'artifact_flag_build_variant_in_try': 'api-16-gradle-artifact',
    'max_build_output_timeout': 0,
}
