#!/bin/sh

ROOT=`dirname $0`/..

# assume main translations are updated and merged in from upstream

# get plugin translations
for locale in en nl; do
	echo -n "plugins-${locale} - "
	curl -# -o "$ROOT/config/locales/plugins-${locale}.yml" "http://www.localeapp.com/projects/6115/downloads/${locale}"
	echo
done

# get foodcoopnl-specific translations
for locale in en nl; do
	echo -n "foodcoopnl-${locale} - "
	curl -# -o "$ROOT/config/locales/foodcoopnl-${locale}.yml" "http://www.localeapp.com/projects/6121/downloads/${locale}"
	echo
done

