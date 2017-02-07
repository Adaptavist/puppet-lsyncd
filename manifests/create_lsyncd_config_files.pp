#
# Helper class to create config files for lsyncd
#
# Parameters:
# -----------
#
# config_files - hash of file resources to create
# 
# 
class lsyncd::create_lsyncd_config_files(
    $config_files = {},
    ){
    validate_hash($config_files)
    create_resources('file', $config_files)
}