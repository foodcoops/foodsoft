# add some more units

if defined? RubyUnits
  RubyUnits::Unit.redefine!('liter') do |unit|
    unit.aliases   += %w{ltr}
  end

  RubyUnits::Unit.redefine!('kilogram') do |unit|
    unit.aliases   += %w{KG}
  end

  RubyUnits::Unit.redefine!('gram') do |unit|
    unit.aliases   += %w{gr}
  end

  RubyUnits::Unit.define('piece') do |unit|
    unit.definition = RubyUnits::Unit.new('1 each')
    unit.aliases    = %w{pc pcs piece pieces}   # locale: en
    unit.aliases   += %w{st stuk stuks}         # locale: nl
    unit.kind       = :counting
  end

  # we use pc for piece, not parsec
  RubyUnits::Unit.redefine!('parsec') do |unit|
    unit.aliases = unit.aliases.reject {|u| u=='pc'}
    unit.display_name = 'parsec'
  end

  # workaround for ruby-units' require mathn warning: "zero and implicit precision is deprecated."
  # default precision of 8 which same as all database definitions in db/migrate/20131213002332_*.rb
  class Rational
    alias orig_to_d to_d
    def to_d(precision=8)
      orig_to_d(precision)
    end
  end
end
