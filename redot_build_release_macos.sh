#!/bin/bash

source config.sh
export godot_version="4.3-stable"
export basedir=$(pwd)
export reldir="${basedir}/releases/${godot_version}"
export binname="Redot_v4.3-stable_macos.universal"
export templatesdir="tmp/templates"

export templates_version=4.3.stable

mkdir -p ${templatesdir}

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
  ssh "${OSX_HOST}" "
            cd ${_macos_tmpdir} && \
            unzip macos.zip && \
            codesign --force -s - \
              --options=linker-signed \
              -v macos_template.app/Contents/MacOS/* && \
            zip -r macos_signed.zip macos_template.app"

  scp "${OSX_HOST}:${_macos_tmpdir}/macos_signed.zip" "${_reldir}/macos.zip"
  ssh "${OSX_HOST}" "rm -rf ${_macos_tmpdir}"
}

## Editor
rm -rf Redot.app
cp -r git/misc/dist/macos_tools.app Redot.app
mkdir -p Redot.app/Contents/{MacOS,Resources}
cp out/macos/tools/redot.macos.editor.universal Redot.app/Contents/MacOS/Redot
chmod +x Redot.app/Contents/MacOS/Redot
zip -q -9 -r "${reldir}/${binname}.zip" Redot.app
rm -rf Redot.app
sign_macos ${reldir} ${binname} 0

  # Templates
rm -rf macos_template.app
cp -r git/misc/dist/macos_template.app .
mkdir -p macos_template.app/Contents/MacOS

cp out/macos/templates/redot.macos.template_release.universal macos_template.app/Contents/MacOS/redot_macos_release.universal
cp out/macos/templates/redot.macos.template_debug.universal macos_template.app/Contents/MacOS/redot_macos_debug.universal
chmod +x macos_template.app/Contents/MacOS/redot_macos*
zip -q -9 -r "${templatesdir}/macos.zip" macos_template.app
rm -rf macos_template.app
sign_macos_template ${templatesdir} 0

echo "${templates_version}" > ${templatesdir}/version.txt
pushd ${templatesdir}/..
zip -q -9 -r -D "${reldir}/${godot_basename}_export_templates.tpz" templates/*
popd