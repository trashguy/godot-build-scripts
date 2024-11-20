#!/bin/bash

set -e

export redot_version=4.3-stable
export template_version=4.3.stable

export basedir=$(pwd)
export reldir="${basedir}/releases/${redot_version}"
export reldir_mono="${reldir}/mono"
export tmpdir="${basedir}/tmp"
export templatesdir="${tmpdir}/templates"
export templatesdir_mono="${tmpdir}/mono/templates"

export redot_basename="Redot_v${redot_version}"

## Templates TPZ (Classical) ##

echo "${template_version}" > ${templatesdir}/version.txt
pushd ${templatesdir}/..
zip -q -9 -r -D "${reldir}/${redot_basename}_export_templates.tpz" templates/*
popd

## SHA-512 sums (Classical) ##

pushd ${reldir}``
sha512sum [Rr]* > SHA512-SUMS.txt
mkdir -p ${basedir}/sha512sums/${redot_version}
cp SHA512-SUMS.txt ${basedir}/sha512sums/${redot_version}/
popd

## Templates TPZ (Mono) ##
echo "TEMPLATES"
echo "${template_version}.mono" > ${templatesdir_mono}/version.txt
pushd ${templatesdir_mono}/..
zip -q -9 -r -D "${reldir_mono}/${redot_basename}_mono_export_templates.tpz" templates/*
popd

## SHA-512 sums (Mono) ##

pushd ${reldir_mono}
sha512sum [Rr]* >> SHA512-SUMS.txt
mkdir -p ${basedir}/sha512sums/${redot_version}/mono
cat SHA512-SUMS.txt > ${basedir}/sha512sums/${redot_version}
popd
