#!/usr/bin/env nu
# Oh My Posh init.nu generator
# Generates init.nu with correct absolute path and embedded --config flag

let omp_path = ("~/AppData/Local/Microsoft/WindowsApps/oh-my-posh.exe" | path expand)
let config_path = ("~/.config/oh-my-posh.json" | path expand)
let output_path = ("~/.cache/oh-my-posh/init.nu" | path expand)

# Use forward slashes to avoid Nushell string escape issues
let omp_path_safe = ($omp_path | str replace --all '\' '/')
let config_path_safe = ($config_path | str replace --all '\' '/')

# Generate the init script
let raw_script = (^$omp_path init nu --config $config_path --print)

# Fix 1: Replace bare exe name with full path
let step1 = ($raw_script | str replace 'echo "oh-my-posh.exe"' $'echo "($omp_path_safe)"')

# Fix 2: Inject POSH_THEME at the top
let step2 = $'$env.POSH_THEME = "($config_path_safe)"' + "\n" + $step1

# Fix 3: Inject --config flag into all OMP print calls
# $env.POSH_THEME is available at runtime (set by init.nu line 1), so reference it in the generated script
let config_flag = $'--config=($config_path_safe)'
let step3 = ($step2
  | str replace --all '^$_omp_executable print $type' $'^$_omp_executable print $type ($config_flag)'
  | str replace --all '^$_omp_executable print secondary' $'^$_omp_executable print secondary ($config_flag)')

$step3 | save -f $output_path
