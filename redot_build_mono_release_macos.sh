#!/bin/bash

source config.sh
export godot_version="4.3-beta"
export basedir=$(pwd)
export reldir="${basedir}/releases/${godot_version}"
export reldir_mono="${reldir}/mono"
export binname="Redot_v4.3-beta_mono_macos.universal"

export templatesdir_mono="${tmpdir}/mono/templates"

export templates_version=4.3.beta

mkdir -p ${templatesdir_mono}

sign_macos() {
  if [ -z "${OSX_HOST}" ]; then
    return
  fi
  _macos_tmpdir=$(ssh "${OSX_HOST}" "mktemp -d")
  echo XXXXX $_macos_tmpdir
  _reldir="$1"
  _binname="$2"
  _is_mono="$3"

  echo ZZZZZ
  echo $_reldir
  echo $_binname
  echo ZZZZZ

  if [[ "${_is_mono}" == "1" ]]; then
    _appname="Redot_mono.app"
    _sharpdir="${_appname}/Contents/Resources/GodotSharp"
  else
    _appname="Redot.app"
  fi

  scp "${_reldir}/${_binname}.zip" "${OSX_HOST}:${_macos_tmpdir}"
  scp "${basedir}/git/misc/dist/macos/editor.entitlements" "${OSX_HOST}:${_macos_tmpdir}"
}

sign_macos_template() {
  if [ -z "${OSX_HOST}" ]; then
    return
  fi
  _macos_tmpdir=$(ssh "${OSX_HOST}" "mktemp -d")
  _reldir="$1"
  _is_mono="$2"

  echo ZZZZZ
  echo $_macos_tmpdir
  echo $_reldir
  echo $_binname
  echo ZZZZZ

  scp "${_reldir}/macos.zip" "${OSX_HOST}:${_macos_tmpdir}"
}

## Editor
rm -rf Godot_mono.app
cp -r git/misc/dist/macos_tools.app Redot_mono.app
mkdir -p Redot_mono.app/Contents/{MacOS,Resources}
cp out/macos/tools-mono/redot.macos.editor.universal.mono Redot_mono.app/Contents/MacOS/Redot
cp -rp out/macos/tools-mono/GodotSharp Redot_mono.app/Contents/Resources/GodotSharp
chmod +x Redot_mono.app/Contents/MacOS/Redot
zip -q -9 -r "${reldir_mono}/${binname}.zip" Redot_mono.app
rm -rf Redot_mono.app
sign_macos ${reldir_mono} ${binname} 1

# Templates
rm -rf macos_template.app
cp -r git/misc/dist/macos_template.app .
mkdir -p macos_template.app/Contents/{MacOS,Resources}
cp out/macos/templates-mono/redot.macos.template_debug.universal.mono macos_template.app/Contents/MacOS/redot_macos_debug.universal
cp out/macos/templates-mono/redot.macos.template_release.universal.mono macos_template.app/Contents/MacOS/redot_macos_release.universal
chmod +x macos_template.app/Contents/MacOS/redot_macos*
zip -q -9 -r "${templatesdir_mono}/macos.zip" macos_template.app
rm -rf macos_template.app
sign_macos_template ${templatesdir_mono} 1


## Templates TPZ (Mono) ##
echo "TEMPLATES"
echo "${templates_version}.mono" > ${templatesdir_mono}/version.txt
pushd ${templatesdir_mono}/..
zip -q -9 -r -D "${reldir_mono}/${godot_basename}_mono_export_templates.tpz" templates/*
popd