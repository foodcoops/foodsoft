require 'spec_helper'
require 'i18n-spec'

Dir.glob('config/locales/??{-*,}.yml').each do |locale_file|
  describe "#{locale_file}" do
    it_behaves_like 'a valid locale file', locale_file
    # We're currently allowing both German and English as source language
    # besides, we're using localeapp, so that it's ok if pull requests
    # don't have this - a localapp pull will fix that right away.
    # it { expect(locale_file).to be_a_subset_of 'config/locales/en.yml' }
  end
end
