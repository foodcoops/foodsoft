# Synopsis

In this PR (addressing [#1058](https://github.com/foodcoops/foodsoft/issues/1058)) we originally wanted to [extend article units](#3-article-unit-system) only, however during development it became clear, that other parts had to be refactored/rewritten too - so it now encompasses these **three major changes**:

1. [Article versioning](#1-article-versioning)
2. [Article list synchronization](#2-article-list-synchronization)
3. [Article unit system](#3-article-unit-system)

Also note, there are some related issues [intentionally left open](#open-todosdiscussions).

# 1. Article versioning

Originally there had been a table called `article_prices` which handled article versioning. However, we identified two issues that we wanted to address:

1. It only versioned article prices and unit sizes, but none of the other article fields like `name`.
2. It duplicated fields from the `articles` table.

So we replaced it by the new table `article_versions`, which now includes all fields relevant to versioning (E.g.: When changing an article name of an article, which is included in a closed order, the name should be left changed when viewing/exporting said order).

`articles` itself no longer duplicates the fields already included in `article_versions`.

See the respective [rails migration here](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/db/migrate/20240726083740_alter_articles_add_versioning.rb).

The rules as to _when_ new versions of article fields are created are unchanged.


**Why did we have to handle this before adapting the article unit system and didn't just do this in a later PR?**

The reasoning was: If we were to keep the `article_prices` logic in place, we'd have to duplicate all those new fields from `articles` into `article_prices` as well. (Causing a huge refactoring once we'd finally would have gotten around to tackling the versioning issues.)

# 2. Article list synchronization

[sharedlists](https://github.com/foodcoops/sharedlists) integration has two design issues as we found:

1. It duplicates details about foodsofts `articles` table, which causes changes to its structure to require also changing `sharedlists` in a lot of places (hard to maintain).
2. It requires a connection to the same db instance as foodsoft.

So we decided provide an alternative for `sharedlists` with a foodsoft feature we called "**supplier sharing**":

- Each supplier may be shared (through a click on the supplier's view page). This causes the field `suppliers.external_uuid` to be filled automatically. With this UUID a share URL is generated, which the user may send to whichever other foodcoop they want to share their supplier's article list with.
- There's no extra authentication for this planned yet. (The link thus shouldn't be made public.)
- The sharing foodcoop may at any time revoke the share on the supplier's view page.
- A foodcoop receiving such a share may connect it to any of its suppliers by entering it as `suppliers.supplier_remote_source` in the suppliers edit form.
- If a supplier as `suppliers.supplier_remote_source` set, users may - same as prior to this change - sync data downstream at the supplier's article index page. (Algorithm still depends on `suppliers.supplier_shared_sync_method`)

The API docs for supplier sharing can be automatically exported to swagger - see the [docs on how to do that](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/doc/API.md#api-endpoint-documentation). (Note the petstore.swagger.io link there doesn't work and even if it would, it would lead to `main`'s API, not to this branch's. You'll need to generate them yourself for now.)

The API endpoint handling sharing is `/shared_suppliers/{uuid}/articles`.

Also see [rails migration here](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/db/migrate/20240726083742_alter_suppliers_sharing_fields.rb).

Not all of `sharedlists`' features have been ported yet. Specifically the [SMTP article list import](https://github.com/foodcoopsat/foodsoft_hackathon/issues/37) is missing. However, it has been agreed, that this is one of the issues, that should only be done after merging this PR (to not further bloat it).

**Why did we have to handle this before adapting the article unit system and didn't just do this in a later PR?**

Maintenance: Updating any article fields always requires updating `sharedlists` models, views as well. This seemed like an unnecessary cost. The new "supplier sharing" API interface is open though: If required, `sharedlists` could still be adapted to use this interface instead of directly accessing foodsoft's db.

# 3. Article unit system

## Unit identification

The current foodsoft's article units are stored in plain text, which has several disadvantages:

1. If one wanted to implement automatic conversions from one unit to another (e.g. kg to g), the result would be error prone. (Any such ruleset would only work for certain conventions of notation and those often vary from foodcoop to foodcoop. Also typos could cause issues.)
2. Limited interoperability with other foodcoops (also due to the aforementioned lack of shared conventions).
3. Limited interoperability with external systems.
4. Limited interoperability with other languages (be it with foodsofts or with external systems)

This is why we decided to use the [UNECE recommendations 20 and 21](https://unece.org/trade/uncefact/cl-recommendations) to allow conversions and enhance interoperability at the same time:

- UNECE 20 provides units conversible to SI units, such as "kilogram" or "litres" (amongst other things, which we didn't use) 
- UNECE 21 provides piece units, such as "package" or "jar" (again: amongst other things, which we didn't use)

The items from these two recommendations contain lots of heterogeneous properties of which foodsoft will only use a few and of which some need to be translated to the respective language (more on that [below](#unit-translations)). They are however all **identified by a unique three-letter code** (e.g. `KGM` for kilogram) which can be used to exchange data with other system.

This code is what is stored to identify a unit instead of foodsoft's former plain text field `articles.unit`.

## Unit selection

As UNECE 20/21 alone would allow for a _lot_ of units to be selected, we felt the need to provide the user with a suggestion for what are _likely_ units in a foodcoop:

In the new article form only units included in the new [`article_units` table](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/db/schema.rb#L67) may be selected.

This table is initially populated with an arbitrary set of units - see [the respective rails migration](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/db/migrate/20240726083743_create_article_units.rb#L11). If the original db seems to contain plain text imperial units, [those are added too](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/db/migrate/20240726083743_create_article_units.rb#L13).

The users with permission `article_meta` may change this preset at any time by using the new [article units page](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/app/controllers/article_units_controller.rb).

## Diversified unit fields

Aside from the issue of unit interoperability and convertibility, we found that it would be helpful to be able to provide different units per article _depending on which page/function is being used_.

The current foodsoft already supports this in a limited fashion: `articles.unit_quantity` was used to split an unnamed compound unit into smaller, named parts. (For example 10 x 100g)

We expanded this by introducing the following fields (see the [respective rails migration](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/db/migrate/20240726083741_alter_articles_add_more_unit_logic.rb)):

- `supplier_order_unit`: Used when sending orders to the supplier. It is also displayed in many other pages throughout the application (e.g. when viewing orders in `default` mode).  
- `minimum_order_quantity`: Required amount before an order may be sent to the supplier
- `group_order_unit`: Used when order groups create/edit group orders etc.
- `group_order_granularity`: Steps in which order groups may order.
- `price_unit`: Useful for entering the price as the supplier listed it, even if amounts are then listed in a different unit. Also used when exporting lists of articles (CSV).
- `billing_unit`: Used for balancing and other pages (e.g. when viewing orders `by_article` or `by_group`)

`unit_quantity` is converted (by the same rails migration) to match the new logic and then dropped. `unit` still exists to allow custom units, but is discouraged. (When entering texts that match `article_units`, a warning is displayed recommending to use those instead of plain text.)

### Unit ratios

The UNECE unit system can automatically convert any SI-based unit to any other unit with the same SI base (for example: kg to dg, g to kg, etc.).

However, in order to also be able to convert piece units (such as package), the user may provide multiple `article_unit_ratios` per article:

- `article_unit_ratios.quantity` always refers to `supplier_order_unit` (or - if legacy `unit` is used - to that) to allow easy calculations within SQL if required. The _display_ in the articles form differs from that: There, only the first ratio refers to `supplier_order_unit`, but each consecutive to the ratio above.)
- `article_unit_ratios.unit` may be any other UNECE unit, but may not have the same SI base as another ratio or as `supplier_order_unit`. (Adding a conversion for kilogram to liter would be fine, but one from `kilogram` to `gram` redundant - the system can do that by itself.)
- `article_unit_ratios.sort` is currently used for sorting ratios in the article form only.

Conversions (regardless of SI-based or by user-provided ratios) can be done using [ArticleVersion.convert_quantity](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/app/models/concerns/price_calculation.rb#L51).

Most quantity inputs in foodsoft now include a button to open a conversion popover allowing access to this functionality.

### Determining required pack sizes for group orders

As the field `unit_quantity` is removed, the amount of articles required to "fill a pack" (aka "pack size") when handling group orders has to be derived from other fields:

- If the `supplier_order_unit` is a SI-conversible unit (such as kg), there is no pack size, that needs to be considered. (`group_order_granularity` and `minimum_order_quantity` still do though.)
- If `supplier_order_unit` is a piece unit (such as "package"), the pack size is the factor one would need to multiply `group_order_unit` with to reach 1x `supplier_order_unit`.

## Migrating from legacy plain text units

To facilitate migrating from the legacy `article_versions.unit` field, the [migrate_units action](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/app/controllers/articles_controller.rb#L109) (accessible from the articles index page), provides a semi-automatic workflow:

1. Ask the user to download a CSV export
2. Show a form grouping the existing articles by their plain text units. For each article an attempt is made to preset UNECE unit fields.
3. The user may then manually alter the suggested values and choose which article to migrate by (un-)checking them in the form.
4. Old orders are of course untouched by this migration (see [Article versioning above](#1-article-versioning))
5. As soon as the migration has completed, [`suppliers.unit_migration_completed`](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/db/migrate/20240726083744_add_unit_migration_completed_to_suppliers.rb) is set causing the button to no longer be displayed on the articles index page.

## Unit translations

The [UNECE data source](https://unece.org/trade/uncefact/cl-recommendations) only includes English unit names/descriptions and even those are not always fit for display, so we need to provide translations.

Since it includes zounds of units only a reasonable subset has been [refined for English](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/config/units-of-measure/locales/unece_en.yml) and [translated to German](https://github.com/foodcoops/foodsoft/blob/84518a7cddac8dfb728213ca2544f5d0067c20d3/config/units-of-measure/locales/unece_de.yml).

The [translations to other languages](https://github.com/foodcoops/foodsoft/tree/84518a7cddac8dfb728213ca2544f5d0067c20d3/config/units-of-measure/locales) currently are only AI generated and thus probably not very reliable.

# Open TODOs/discussions

To not let the size of this PR explode any further, we agreed to postpone several issues/discussions until after it has been merged.

Those currently live at the fork's GitHub page: https://github.com/foodcoopsat/foodsoft_hackathon/issues.

As soon as the merge and all discussions leading up to it have been completed, they should be moved upstream of course (in case they're still relevant). On the plus side this will close some existing issues - see [twothreenine's comment here](https://github.com/foodcoops/foodsoft/pull/1073#issuecomment-2464488951).
