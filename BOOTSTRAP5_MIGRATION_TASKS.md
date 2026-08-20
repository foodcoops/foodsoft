# Bootstrap 5 Migration Tasks

## Progress Checklist

- [ ] **Phase 0A — Fix Modals** (broken functionality)
  - [x] 0A-1: Add inner modal structure to layout
  - [x] 0A-2: Update modal show calls (21 instances)
  - [x] 0A-3: Update modal hide calls (13 instances)
  - [x] 0A-4: Update data-dismiss="modal" → data-bs-dismiss="modal" (17 instances)
  - [x] 0A-5: Handle .modal-xl class additions (4 instances)
- [ ] **Phase 0B — Fix Tooltips** (broken functionality)
  - [x] 0B-1: Replace global tooltip init in application_legacy.js
  - [x] 0B-2: Fix self_service tooltips
  - [x] 0B-3: Rename data-toggle="tooltip" → data-bs-toggle="tooltip" (6 instances)
- [ ] **Phase 0C — Fix Popovers** (broken functionality)
  - [x] 0C-1: Rewrite unit-conversion-field.js
- [ ] **Phase 1 — SimpleForm Config**
  - [x] 1-1: Rewrite simple_form_bootstrap.rb for BS5
  - [x] 1-2: Update simple_form.rb label_class
- [ ] **Phase 2 — Mechanical Replacements**
- [x] 2-1: btn-xs → btn-sm (73 instances)
- [x] 2-2: pull-right → float-end (27 instances)
- [x] 2-3: pull-left → float-start (8 instances)
- [x] 2-4: ml-* → ms-*, mr-* → me-* (35 instances)
- [x] 2-5: pl-* → ps-*, pr-* → pe-* (1 instance)
- [x] 2-6: text-left → text-start, text-right → text-end (3 instances)
- [x] 2-7: hidden-xs → d-none d-sm-block (2 instances)
- [x] 2-8: data-toggle → data-bs-toggle (14 instances, non-tooltip)
- [x] 2-9: data-dismiss → data-bs-dismiss (1 instance, non-modal)
- [x] 2-10: badge-important → badge bg-danger (1 instance)
- [x] 2-11: Offset classes col-*-offset-* → offset-*-* (2 instances)
- [x] **Phase 3 — Structural Component Changes**
  - [x] 3-1: .well/.well-small → .card/.card-body (27 instances)
  - [x] 3-2: .panel → .card (1 file)
  - [x] 3-3: .page-header → remove (4 instances)
  - [x] 3-4: .input-group-btn → .input-group (6 instances)
  - [x] 3-5: Mollie .control-group form restructured; SCSS refs remain for Phase 5
  - [x] 3-6: .form-group → .mb-3 (24 instances hardcoded)
  - [x] 3-7: .btn-toolbar needs .gap-2 for spacing (6 instances)
  - [x] 3-8: Dropdown toggle `<a>` → `<button>` (10 instances; navbar kept per BS5 spec)
  - [x] 3-9: Tab component — BS5 structure (nav-link, role, aria attributes)
- [x] **Phase 4 — Icon Replacement**
  - [x] 4-1: glyphicon → FontAwesome in views (22 instances)
  - [x] 4-2: icon-* → fa fa-* in views (8 instances)
  - [x] 4-3: glyphicon → FontAwesome in Ruby helpers
  - [x] 4-4: glyphicon → FontAwesome in JavaScript
  - [x] 4-5: Remove glyphicon SCSS references
- [x] **Phase 5 — CSS Cleanup**
  - [x] 5-1: Delete dead file app/assets/javascripts/bootstrap.js
  - [x] 5-2: Remove manually-defined BS5-native utility classes from SCSS
  - [x] 5-3: Remove legacy form CSS from SCSS
  - [x] 5-4: Remove legacy panel CSS from SCSS
  - [x] 5-5: Remove pull-left/pull-right fallback CSS
- [ ] **Phase 6 — View-by-View Manual Review** (135 HAML files)

### Layouts
- [x] `app/views/layouts/application.html.haml`
- [x] `app/views/layouts/login.html.haml`
- [x] `app/views/layouts/_footer.html.haml`

### Home & Navigation
- [x] `app/views/home/index.html.haml`
- [x] `app/views/home/ordergroup.html.haml`
- [x] `app/views/home/_start_nav.html.haml`

### Orders
- [x] `app/views/orders/_form.html.haml`
- [x] `app/views/orders/_articles.html.haml`
- [x] `app/views/orders/_edit_amount.html.haml`
- [x] `app/views/orders/show.html.haml`
- [x] `app/views/orders/index.html.haml`
- [x] `app/views/orders/receive.html.haml`

### Group Orders
- [x] `app/views/group_orders/_form.html.haml`
- [x] `app/views/group_orders/show.html.haml`
- [x] `app/views/group_orders/index.html.haml`
- [ ] `app/views/group_order_articles/_form.html.haml`

### Articles
- [x] `app/views/articles/_form.html.haml`
- [x] `app/views/articles/_sync_table.html.haml`
- [x] `app/views/articles/_edit_all_table.html.haml`
- [x] `app/views/articles/_article.html.haml`
- [x] `app/views/articles/index.html.haml`
- [x] `app/views/articles/migrate_units.html.haml`

### Stockit / StockTakings / Deliveries
- [x] `app/views/stockit/_form.html.haml`
- [x] `app/views/stockit/index.html.haml`
- [x] `app/views/stockit/_stock_article.html.haml`
- [x] `app/views/stock_takings/index.html.haml`
- [x] `app/views/stock_takings/show.html.haml`
- [x] `app/views/stock_takings/_stock_change.html.haml`
- [x] `app/views/stock_takings/_stock_takings.html.haml`
- [x] `app/views/deliveries/index.html.haml`
- [x] `app/views/deliveries/_stock_article_for_adding.html.haml`
- [x] `app/views/deliveries/_stock_change_fields.html.haml`

### Suppliers
- [x] `app/views/suppliers/index.html.haml`
- [x] `app/views/suppliers/show.html.haml`
- [ ] `app/views/suppliers/_import_search_results.html.haml`

### Finance — Balancing
- [x] `app/views/finance/balancing/new.html.haml`
- [x] `app/views/finance/balancing/_edit_results_by_articles.html.haml`
- [x] `app/views/finance/balancing/_group_order_articles.html.haml`
- [x] `app/views/finance/balancing/_order_article.html.haml`
- [x] `app/views/finance/balancing/_edit_note.html.haml`
- [x] `app/views/finance/balancing/_edit_transport.html.haml`

### Finance — Bank & Transactions
- [x] `app/views/finance/bank_transactions/index.html.haml`
- [ ] `app/views/finance/bank_transactions/_transactions.html.haml`
- [ ] `app/views/finance/bank_accounts/_import.html.haml`
  - **Note:** Dummy Bank Gateway missing in order to test templates
- [x] `app/views/finance/financial_transactions/index.html.haml`
- [x] `app/views/finance/financial_transactions/_transactions.html.haml`
- [x] `app/views/finance/financial_transactions/_transactions_search.html.haml`
- [x] `app/views/finance/financial_transactions/new_collection.html.haml`

### Finance — Links, Ordergroups
- [x] `app/views/finance/financial_links/_index_bank_transaction.html.haml`
- [x] `app/views/finance/financial_links/_index_financial_transaction.html.haml`
- [x] `app/views/finance/financial_links/_index_invoice.html.haml`
- [x] `app/views/finance/financial_links/_new_financial_transaction.html.haml`
- [x] `app/views/finance/financial_links/show.html.haml`
- [x] `app/views/finance/ordergroups/index.html.haml`
- [x] `app/views/finance/ordergroups/_ordergroups.html.haml`

### Finance — Index
- [x] `app/views/finance/index.html.haml`

### Finance — Invoices, Balancing
- [x] `app/views/finance/invoices/_form.html.haml`
- [x] `app/views/finance/invoices/_invoices.html.haml`
- [x] `app/views/finance/invoices/show.html.haml`
- [x] `app/views/finance/balancing/confirm.html.haml`
- [x] `app/views/finance/balancing/index.html.haml`


### Admin — Configs
- [x] `app/views/admin/configs/_tabs.html.haml`
- [x] `app/views/admin/configs/show.html.haml`
- [x] `app/views/admin/configs/_tab_payment.html.haml`

### Admin — Users & Workgroups
- [x] `app/views/admin/users/_form.html.haml`
- [x] `app/views/admin/users/index.html.haml`
- [x] `app/views/admin/users/show.html.haml`
- [x] `app/views/admin/users/_users.html.haml`
- [x] `app/views/admin/workgroups/_form.html.haml`
- [x] `app/views/admin/workgroups/index.html.haml`
- [x] `app/views/admin/workgroups/_workgroups.html.haml`

### Admin — Finances
- [x] `app/views/admin/finances/index.html.haml`
- [x] `app/views/admin/finances/_bank_gateways.html.haml`
- [x] `app/views/admin/finances/_supplier_categories.html.haml`
- [x] `app/views/admin/finances/_transaction_types.html.haml`
- [x] `app/views/admin/financial_transaction_classes/_form.html.haml`
- [x] `app/views/admin/financial_transaction_types/_form.html.haml`

### Admin — Misc
- [x] `app/views/admin/ordergroups/index.html.haml`
- [x] `app/views/admin/ordergroups/_ordergroups.html.haml`
- [x] `app/views/admin/bank_accounts/_form.html.haml`
- [x] `app/views/admin/bank_gateways/_form.html.haml`
- [x] `app/views/admin/supplier_categories/_form.html.haml`
- [x] `app/views/admin/mail_delivery_status/_maildeliverystatus.html.haml`

### Sessions
- [x] `app/views/sessions/new.html.haml`

### Shared Partials
- [x] `app/views/shared/_article_fields_units.html.haml`
- [x] `app/views/shared/_article_fields_price.html.haml`
- [ ] `app/views/shared/_article_unit_ratio.html.haml`
  - **Note:** The unit `<select>` on line 13 is enhanced by **select2** via `article-form.js:302` (`select$.select2(this.select2Config)`). Select2 bundles a Bootstrap-version-specific theme CSS. With BS5, either:
    - Install `select2-bootstrap-5-theme` (npm package), or
    - Replace select2 with a BS5-native alternative (plain `<select>` with `.form-select`, or a custom dropdown)
    - The select is also used in `_article_fields_units.html.haml:13`, `_edit_all_table.html.haml:38`, and `_sync_table.html.haml:49`
- [x] `app/views/shared/_user_form_fields.html.haml`
- [x] `app/views/shared/_task_list.html.haml`
- [ ] `app/views/shared/_order_download_button.html.haml`
- [x] `app/views/shared/_alert_success.haml`
- [x] `app/views/shared/_workgroup_members.html.haml`
- [x] `app/views/shared/articles_by/_articles.html.haml`
- [x] `app/views/shared/articles_by/_article_single.html.haml`
- [x] `app/views/shared/articles_by/_article_single_goa.html.haml`
- [ ] `app/views/shared/articles_by/_availability_explanation.html.haml`
- [x] `app/views/shared/articles_by/_group_single_goa.html.haml`
- [x] `app/views/shared/js_templates/_unit_conversion_popover_template.haml`

### Self Service
- [ ] `app/views/self_service/_event_listeners.haml`
  - **Note:** On availability column the availability explanation is displayed twice if the event listener has been toggled before. 
- [x] `app/views/self_service/index.haml`
- [x] `app/views/self_service/_pickup.haml`

### Tasks, Errors, Pickups, Invites, Workgroups
- [x] `app/views/tasks/edit.haml`
- [x] `app/views/tasks/_nav.haml`
- [x] `app/views/errors/_error.html.haml`
- [x] `app/views/invites/_modal_form.html.haml`
- [x] `app/views/pickups/index.html.haml`
- [x] `app/views/foodcoop/workgroups/edit.html.haml`
- [x] `app/views/foodcoop/workgroups/_workgroup.html.haml`

### Article Units & Categories
- [x] `app/views/article_units/index.html.haml`
- [x] `app/views/article_units/_create_link.html.haml`
- [x] `app/views/article_units/_destroy_link.html.haml`
- [x] `app/views/article_categories/index.html.haml`

### Plugins — Current Orders
- [ ] `plugins/current_orders/.../ordergroups/_form.html.haml`
- [ ] `plugins/current_orders/.../ordergroups/_payment_bar.html.haml`
- [ ] `plugins/current_orders/.../articles/_form.html.haml`
- [ ] `plugins/current_orders/.../articles/_actions.html.haml`
- [ ] `plugins/current_orders/.../group_orders/_result.html.haml`
- [ ] `plugins/current_orders/.../group_orders/_payment_bar.html.haml`

### Plugins — Messages
- [ ] `plugins/messages/.../messages/thread.haml`
- [ ] `plugins/messages/.../messages/show.html.haml`
- [ ] `plugins/messages/.../messages/_messages.html.haml`
- [ ] `plugins/messages/.../messagegroups/_messagegroup.html.haml`
- [ ] `plugins/messages/.../admin/messagegroups/_form.html.haml`
- [ ] `plugins/messages/.../admin/messagegroups/index.html.haml`
- [ ] `plugins/messages/.../admin/messagegroups/_messagegroups.html.haml`
- [ ] `plugins/messages/.../message_threads/_groupmessage_threads.html.haml`

### Plugins — Wiki
- [x] `plugins/wiki/.../pages/show.html.haml`
- [x] `plugins/wiki/.../pages/all.html.haml`
- [x] `plugins/wiki/.../pages/_form.html.haml`
- [x] `plugins/wiki/.../pages/_body.html.haml`

### Plugins — Polls
- [x] `plugins/polls/.../polls/_polls.html.haml`
- [x] `plugins/polls/.../polls/_form.html.haml`
- [x] `plugins/polls/.../polls/index.html.haml`
- [x] `plugins/polls/.../polls/show.html.haml`
- [x] `plugins/polls/.../polls/vote.html.haml`

### Plugins — Documents
- [x] `plugins/documents/.../documents/_form.html.haml`
- [x] `plugins/documents/.../documents/_documents.html.haml`
- [x] `plugins/documents/.../documents/_move.html.haml`
- [x] `plugins/documents/.../documents/index.html.haml`

### Plugins — Links, Mollie
- [x] `plugins/links/.../admin/links/_form.html.haml`
- [x] `plugins/links/.../admin/links/_links.html.haml`
- [x] `plugins/mollie/.../payments/mollie/_form.html.haml`

### Scaffold
- [x] `lib/templates/haml/scaffold/_form.html.haml`


---

## Current State

- **Bootstrap 5.3** installed via gem (dartsass-sprockets pipeline)
- **334 view files** (301 HAML, 33 ERB), +80 plugin views — **135 HAML files** touched across Phases 0-5
- JS delivered via dual pipeline: Importmap (BS5 JS) + Sprockets (legacy jQuery)
- Phases 0-5: **complete** — modals, tooltips, popovers, forms, icons, CSS all migrated

---

## Phase 0A — Fix Modals (CRITICAL — currently broken)

### 0A-1: Add inner modal structure to layout
**File:** `app/views/layouts/application.html.haml:53`
Replace bare `<div id="modalContainer" class="modal fade">` with:
```haml
#modalContainer.modal.fade(tabindex="-1")
  .modal-dialog
    .modal-content
```

### 0A-2: Update modal "show" calls (21 instances)
Replace `$('#modalContainer').modal()` with `new bootstrap.Modal('#modalContainer').show()`:

| # | File | Line |
|---|------|------|
| 1 | `app/views/group_order_articles/new.js.erb` | 2 |
| 2 | `app/views/order_articles/new.js.haml` | 2 |
| 3 | `app/views/order_articles/edit.js.haml` | 2 |
| 4 | `app/views/articles/new.js.haml` | 2 |
| 5 | `app/views/articles/copy.js.haml` | 2 |
| 6 | `app/views/stockit/new.js.erb` | 9 |
| 7 | `app/views/stockit/edit.js.erb` | 9 |
| 8 | `app/views/stockit/derive.js.erb` | 9 |
| 9 | `app/views/stockit/copy.js.erb` | 9 |
| 10 | `app/views/invites/new.js.haml` | 2 |
| 11 | `app/views/admin/bank_accounts/new.js.haml` | 2 |
| 12 | `app/views/admin/bank_gateways/new.js.haml` | 2 |
| 13 | `app/views/admin/supplier_categories/new.js.haml` | 2 |
| 14 | `app/views/admin/financial_transaction_types/new.js.haml` | 2 |
| 15 | `app/views/admin/financial_transaction_classes/new.js.haml` | 2 |
| 16 | `app/views/finance/financial_links/new_financial_transaction.js.haml` | 2 |
| 17 | `app/views/finance/financial_links/index_invoice.js.haml` | 2 |
| 18 | `app/views/finance/financial_links/index_financial_transaction.js.haml` | 2 |
| 19 | `app/views/finance/financial_links/index_bank_transaction.js.haml` | 2 |
| 20 | `app/views/finance/balancing/edit_transport.js.haml` | 2 |
| 21 | `app/views/finance/balancing/edit_note.js.haml` | 2 |

### 0A-3: Update modal "hide" calls (13 instances)
Replace `$('#modalContainer').modal('hide')` with `bootstrap.Modal.getInstance('#modalContainer').hide()`:

| # | File | Line |
|---|------|------|
| 1 | `app/views/group_order_articles/create.js.erb` | 1 |
| 2 | `app/views/order_articles/create.js.erb` | 8 |
| 3 | `app/views/order_articles/update.js.erb` | 8 |
| 4 | `app/views/articles/create.js.haml` | 1 |
| 5 | `app/views/articles/update.js.haml` | 2 |
| 6 | `app/views/invites/create.js.haml` | 1 |
| 7 | `app/views/stockit/create.js.erb` | 15 |
| 8 | `app/views/stockit/update.js.erb` | 15 |
| 9 | `app/views/admin/finances/update_bank_gateways.js.haml` | 2 |
| 10 | `app/views/admin/finances/update_supplier_categories.js.haml` | 2 |
| 11 | `app/views/admin/finances/update_transaction_types.js.haml` | 2 |
| 12 | `app/views/admin/finances/update_bank_accounts.js.haml` | 2 |
| 13 | `app/views/finance/balancing/update_note.js.haml` | 1 |

### 0A-4: Update `data-dismiss="modal"` → `data-bs-dismiss="modal"` in modal forms (17 instances)
Find: `data: { dismiss: 'modal' }` or `'data-dismiss' => 'modal'`
Replace with: `'data-bs-dismiss' => 'modal'`

| # | File | Line |
|---|------|------|
| 1 | `app/views/group_order_articles/_form.html.haml` | 12 |
| 2 | `app/views/stockit/_form.html.haml` | 52 |
| 3 | `app/views/order_articles/_edit.html.haml` | 37 |
| 4 | `app/views/order_articles/_new.html.haml` | 10 |
| 5 | `app/views/finance/financial_links/_index_financial_transaction.html.haml` | 26 |
| 6 | `app/views/finance/financial_links/_new_financial_transaction.html.haml` | 15 |
| 7 | `app/views/finance/financial_links/_index_invoice.html.haml` | 22 |
| 8 | `app/views/finance/financial_links/_index_bank_transaction.html.haml` | 22 |
| 9 | `app/views/articles/_form.html.haml` | 29 |
| 10 | `app/views/invites/_modal_form.html.haml` | 13 |
| 11 | `app/views/admin/bank_accounts/_form.html.haml` | |
| 12 | `app/views/admin/bank_gateways/_form.html.haml` | |
| 13 | `app/views/admin/financial_transaction_classes/_form.html.haml` | |
| 14 | `app/views/admin/financial_transaction_types/_form.html.haml` | |
| 15 | `app/views/admin/supplier_categories/_form.html.haml` | |
| 16 | `app/views/finance/balancing/_edit_transport.html.haml` | |
| 17 | `app/views/finance/balancing/_edit_note.html.haml` | |

### 0A-5: Handle `.modal-xl` class additions
Some JS files add `.modal-xl` to `#modalContainer`:
- `app/views/articles/update.js.haml:2`
- `app/views/order_articles/edit.js.haml:1`
- `app/views/articles/new.js.haml:1`
- `app/views/stockit/new.js.erb:4`

In BS5, `.modal-xl` goes on `.modal-dialog`, not `.modal`. Update these to:
```js
$('#modalContainer .modal-dialog').addClass('modal-xl');
// or for removal:
$('#modalContainer .modal-dialog').removeClass('modal-xl');
```

---

## Phase 0B — Fix Tooltips (CRITICAL — currently broken)

### 0B-1: Replace global tooltip init in application_legacy.js
**File:** `app/assets/javascripts/application_legacy.js:163-171`
Replace jQuery `$.fn.tooltip` + `$(document).tooltip({selector:...})` with BS5 native API using MutationObserver or event delegation.

### 0B-2: Fix self_service tooltips
**File:** `app/views/self_service/_event_listeners.haml:82-86,98-102`
Replace `$('.availability[data-toggle="tooltip"]').tooltip({...})` with `new bootstrap.Tooltip(element, {...})`
Also: `.tooltip('fixTitle')` → `.setContent({'.tooltip-inner': newTitle})` (line 10)

### 0B-3: Rename `data-toggle="tooltip"` → `data-bs-toggle="tooltip"` (6 instances)
| # | File | Line |
|---|------|------|
| 1 | `app/views/shared/_user_form_fields.html.haml` | 20 |
| 2 | `app/views/shared/articles_by/_group_single_goa.html.haml` | 7 |
| 3 | `app/views/deliveries/_stock_change_fields.html.haml` | 7 |
| 4 | `app/views/deliveries/_stock_article_for_adding.html.haml` | 7 |
| 5 | `app/views/stock_takings/_stock_change.html.haml` | 8 |
| 6 | `app/assets/javascripts/application_legacy.js` | 170 (selector `[data-toggle~="tooltip"]`) |

---

## Phase 0C — Fix Popovers (CRITICAL — currently broken)

### 0C-1: Rewrite unit-conversion-field.js
**File:** `app/assets/javascripts/unit-conversion-field.js:67,86,92`
Replace `$(el).popover({...})` with `new bootstrap.Popover(el, {...})`
Replace `.popover('show')` → `.show()`
Replace `.popover('hide')` → `.hide()`

---

## Phase 1 — Simple Form Configuration (affects ALL forms globally)

### 1-1: Rewrite SimpleForm config for Bootstrap 5
**File:** `config/initializers/simple_form_bootstrap.rb` (228 lines)

Required changes:
- Default wrapper `form-horizontal` → BS5 grid pattern (remove class entirely, use `.row` wrappers)
- `help-block` class → `form-text` (in error/hint components)
- `has-error` error class → `is-invalid`
- `control-label` class → `form-label` or `col-form-label`
- `col-sm-offset-3` → `offset-sm-3`
- Remove `.input-prepend` and `.input-append` wrapper definitions (use `input-group` directly)
- Remove `.form-group` wrapper class → use `mb-3` spacing
- Update default wrapper from `:horizontal_form` to BS5-compatible
- Remove `class: 'form-horizontal'` default form class

### 1-2: Update SimpleForm base config
**File:** `config/initializers/simple_form.rb:98`
Change `config.label_class = 'control-label'` → `config.label_class = 'form-label'`

---

## Phase 2 — Mechanical Replacements (safe sed, no structural change)

### 2-1: `btn-xs` → `btn-sm` (73 instances)
Safe global replace. Key files:
- `app/views/finance/balancing/_edit_results_by_articles.html.haml`
- `app/views/finance/balancing/_group_order_articles.html.haml`
- `app/views/finance/balancing/_order_article.html.haml`
- `app/views/finance/bank_transactions/_transactions.html.haml`
- `app/views/finance/financial_transactions/_transactions.html.haml`
- `app/views/finance/invoices/_invoices.html.haml`
- `app/views/finance/ordergroups/_ordergroups.html.haml`
- `app/views/articles/_article.html.haml`
- `app/views/deliveries/` (multiple)
- `app/views/suppliers/` (multiple)
- `app/views/stockit/`, `app/views/stock_takings/`
- `app/views/shared/` (multiple)
- `plugins/links/`, `plugins/documents/`, `plugins/polls/`, `plugins/printer/`, `plugins/messages/`

### 2-2: `pull-right` → `float-end` (~36 instances)
Key files:
- `app/views/layouts/application.html.haml:37,46`
- `app/views/layouts/_footer.html.haml:3`
- `app/views/group_orders/_form.html.haml:28,57,158,174`
- `app/views/group_orders/show.html.haml:10,37,46`
- `app/views/orders/show.html.haml:56`
- `app/views/orders/receive.html.haml:44`
- `app/views/articles/index.html.haml:14,45`
- `app/views/shared/articles_by/_articles.html.haml:19`
- `app/views/shared/articles_by/_article_single.html.haml:5`
- `app/views/finance/invoices/_invoices.html.haml:1`
- `app/views/finance/bank_transactions/`, `finance/financial_transactions/`
- `app/views/suppliers/show.html.haml`, `app/views/stockit/index.html.haml`
- `app/views/admin/configs/`, `app/views/article_units/`
- `plugins/current_orders/`, `plugins/wiki/`, `plugins/messages/`, `plugins/printer/`

### 2-3: `pull-left` → `float-start` (~3 instances)
- `app/views/finance/financial_transactions/new_collection.html.haml`
- `app/views/home/index.html.haml`
- `plugins/messages/app/views/messages/thread.haml`

### 2-4: `ml-{n}` → `ms-{n}`, `mr-{n}` → `me-{n}` (~41 instances)
Safe regex: `ml-(\d)` → `ms-\1`, `mr-(\d)` → `me-\1`

Key files:
- `app/views/orders/index.html.haml`
- `app/views/shared/_article_fields_units.html.haml`
- `app/views/shared/_article_fields_price.html.haml`
- `app/views/home/index.html.haml`
- `app/views/articles/_sync_table.html.haml`
- `app/views/articles/_edit_all_table.html.haml`
- `app/views/article_units/index.html.haml`
- `app/views/stockit/_form.html.haml`
- `app/views/sessions/new.html.haml`
- `app/views/admin/configs/show.html.haml`
- `app/assets/javascripts/receive-order-form.js`
- `app/assets/javascripts/article-form.js`
- `app/assets/stylesheets/bootstrap_and_overrides.css.scss`

### 2-5: `pl-{n}` → `ps-{n}`, `pr-{n}` → `pe-{n}` (~13 instances)
- `app/assets/stylesheets/bootstrap_and_overrides.css.scss:687,691`
- `app/views/articles/_sync_table.html.haml`
- `app/views/articles/_edit_all_table.html.haml`
- `app/views/home/index.html.haml`

### 2-6: `text-left` → `text-start`, `text-right` → `text-end` (4 instances)
| File | Line |
|------|------|
| `app/assets/stylesheets/bootstrap_and_overrides.css.scss` | 642 |
| `app/views/shared/js_templates/_unit_conversion_popover_template.haml` | 6 |
| `app/views/shared/articles_by/_availability_explanation.html.haml` | 1, 30 |

### 2-7: `hidden-xs` → `d-none d-sm-block` (2 instances)
- `app/views/errors/_error.html.haml:4`
- `app/helpers/orders_helper.rb:94`
- Also: `.hidden` → `.d-none` in `app/views/group_orders/_form.html.haml:212`

### 2-8: `data-toggle` → `data-bs-toggle` (18 instances, non-tooltip non-modal)
- `app/views/self_service/index.haml:10,12` (tab)
- `plugins/links/app/views/admin/links/_form.html.haml:11` (collapse)
- Dropdown toggles (10 instances): `data: {toggle: 'dropdown'}` → `data-bs-toggle="dropdown"`
  - `app/views/orders/index.html.haml:5`
  - `app/views/articles/index.html.haml:5`
  - `app/views/shared/_order_download_button.html.haml:2`
  - `app/views/stockit/index.html.haml:35,49`
  - `app/views/finance/financial_links/show.html.haml:7`
  - `app/views/finance/balancing/new.html.haml:67,75`
  - `app/views/finance/balancing/_edit_results_by_articles.html.haml:42`
  - `plugins/current_orders/.../articles/_actions.html.haml:2`

### 2-9: `data-dismiss` → `data-bs-dismiss` (18 instances, non-modal)
Alert: `app/views/stockit/_destroy_fail.js.haml:2` (`data-dismiss="alert"`)

### 2-10: `badge-important` → `badge bg-danger` (1 instance)
- `app/helpers/tasks_helper.rb:12`

### 2-11: Offset classes (3 instances)
| Find | Replace | File | Line |
|------|---------|------|------|
| `col-md-offset-3` | `offset-md-3` | `app/views/layouts/login.html.haml` | 4 |
| `col-sm-offset-2` | `offset-sm-2` | `app/views/foodcoop/workgroups/edit.html.haml` | 10 |
| `col-sm-offset-3` | `offset-sm-3` | `config/initializers/simple_form_bootstrap.rb` | 140 |

---

## Phase 3 — Structural Component Changes (manual per-instance)

### 3-1: `.well` / `.well-small` → `.card` / `.card-body` (27 instances, ~15 files)
Replace `%div.well.well-small` → `%div.card` with `.card-body` where content inside.

Key files:
- `app/views/finance/ordergroups/index.html.haml:10`
- `app/views/finance/balancing/new.html.haml:36,40,44,53`
- `app/views/finance/bank_transactions/index.html.haml:7`
- `app/views/finance/financial_transactions/index.html.haml:9`
- `app/views/finance/financial_transactions/new_collection.html.haml:46`
- `app/views/finance/financial_transactions/_transactions_search.html.haml:1`
- `app/views/group_orders/index.html.haml:4`
- `app/views/stockit/index.html.haml:32`
- `app/views/stock_takings/index.html.haml:3`
- `app/views/home/` (multiple)
- `plugins/` (polls, messages)

Also remove `.well` SCSS in `app/assets/stylesheets/bootstrap_and_overrides.css.scss:448`

### 3-2: `.panel` → `.card` (7 instances, 2 files)
- `plugins/messages/app/views/messages/thread.haml:8,9,13,17` → `.panel` → `.card`, `.panel-heading` → `.card-header`, `.panel-body` → `.card-body`
- Remove `app/assets/stylesheets/bootstrap_and_overrides.css.scss:579-606` (custom panel CSS)

### 3-3: `.page-header` → remove or custom CSS (4 instances)
- `app/views/layouts/application.html.haml:39,48`
- `app/views/layouts/login.html.haml:7`
- `plugins/wiki/app/views/pages/show.html.haml:45`

### 3-4: `.input-group-btn` → `.input-group` (7 instances)
- `app/inputs/delta_input.rb:33` — rewrite to use `.input-group > .btn`
- `app/helpers/orders_helper.rb:139`
- `app/views/group_orders/_form.html.haml:127,145`
- `app/assets/javascripts/receive-order-form.js:135`
- `app/assets/javascripts/unit-conversion-field.js:26`

### 3-5: `.control-group` → remove or `.mb-3` (12 instances in SCSS + Ruby)
These are mostly in SCSS and SimpleForm config. Views don't use it directly. Handle during Phase 1 (SimpleForm config).

### 3-6: `.form-group` → `.mb-3` in hardcoded forms (18 instances)
Forms that explicitly write `.form-group` (not via SimpleForm wrapper):
- `app/views/sessions/new.html.haml:18,23,28`
- `app/views/finance/bank_accounts/_import.html.haml:9,30`
- `app/views/finance/invoices/_form.html.haml:5,11,32`
- `app/views/articles/_sync_table.html.haml:54,82`
- `app/views/articles/_edit_all_table.html.haml:43`
- `app/views/stockit/_form.html.haml:30`
- `app/views/shared/_article_fields_units.html.haml:4,16,33`
- `app/views/shared/_article_fields_price.html.haml:1`
- `app/views/foodcoop/workgroups/edit.html.haml:9`

Note: many of these also have `control-label` that needs updating.

### 3-7: `.btn-toolbar` spacing — add `.gap-2` (6 instances)
In BS5, `.btn-toolbar` no longer adds automatic spacing between child `.btn-group` elements. Add `.gap-2` to all `.btn-toolbar` containers.

| # | File | Line |
|---|------|------|
| 1 | `app/views/layouts/application.html.haml` | 37 |
| 2 | `app/views/layouts/application.html.haml` | 46 |
| 3 | `app/views/orders/show.html.haml` | 55 |
| 4 | `app/views/orders/show.html.haml` | 62 |
| 5 | `app/views/articles/index.html.haml` | 13 |
| 6 | `app/views/stockit/index.html.haml` | 33 |

Also: `.pull-right` on layout toolbar → `.float-end` (overlaps with Phase 2-2).

### 3-8: Dropdown toggle `<a>` → `<button>` (12 instances)
BS5 dropdown toggles should be `<button>` elements with `type="button"` and `aria-expanded="false"`, not `<a>` links. Replace all `= link_to '#'` dropdown toggles with `%button`.

Also: `data: {toggle: 'dropdown'}` → `data-bs-toggle="dropdown"` on these elements (overlaps with Phase 2-8).

| # | File | Line |
|---|------|------|
| 1 | `app/views/orders/index.html.haml` | 5 |
| 2 | `app/views/articles/index.html.haml` | 5 |
| 3 | `app/views/shared/_order_download_button.html.haml` | 2 |
| 4 | `app/views/stockit/index.html.haml` | 35 |
| 5 | `app/views/stockit/index.html.haml` | 49 |
| 6 | `app/views/finance/financial_links/show.html.haml` | 7 |
| 7 | `app/views/finance/balancing/new.html.haml` | 67 |
| 8 | `app/views/finance/balancing/new.html.haml` | 75 |
| 9 | `app/views/finance/balancing/_edit_results_by_articles.html.haml` | 42 |
| 10 | `plugins/current_orders/app/views/current_orders/articles/_actions.html.haml` | 2 |

### 3-9: Tab component — `.nav-link`, `role`, `aria` attributes (admin/configs)
BS5 tabs require additional classes and accessibility attributes:
- `<ul class="nav">` needs `role="tablist"`
- Each tab `<a>` needs `.nav-link`, `role="tab"`, `aria-selected="true/false"`
- `<li>` wrappers need `.nav-item`, `role="presentation"`
- `.tab-pane` divs need `role="tabpanel"`, `aria-labelledby`

**Files:**
| # | File | Changes |
|---|------|---------|
| 1 | `app/views/admin/configs/_tabs.html.haml` | Add `.nav-link`, `role="tab"`, `aria-selected`, `.nav-item`, `role="tablist"` |
| 2 | `app/views/admin/configs/show.html.haml` | Add `role="tabpanel"` to `.tab-pane`, fix submit button layout |

Required structural changes:

`_tabs.html.haml`:
```haml
%ul.nav.nav-tabs(role="tablist")
  %li.nav-item.heading(role="presentation")
    %h1= t '.title'
  - for tab in @tabs
    - url = action_name == 'show' ? nil : admin_config_path(tab: tab)
    %li.nav-item(role="presentation")
      = link_to t("config.tabs.#{tab}"), "#{url}#tab-#{tab}",
        class: "nav-link #{'active' if @current_tab==tab}",
        data: ({'bs-toggle': 'tab'} unless url),
        role: "tab",
        'aria-selected' => (@current_tab==tab).to_s
  %li.nav-item.float-end(role="presentation")
    = link_to t('config.tabs.list'), list_admin_config_path, class: 'nav-link'
  %li.nav-item.float-end(role="presentation")
    = link_to t('config.tabs.applications'), oauth_applications_path, class: 'nav-link'
```

`show.html.haml`:
```haml
.tab-content
  - for tab in @tabs
    .tab-pane.fade.show.active{id: "tab-#{tab}", role: "tabpanel", class: ('active' if @current_tab==tab)}
      = render "tab_#{tab}", form: f
.text-end
  = f.submit t('.submit'), class: 'btn btn-primary'
```

---


### 4-1: Replace all glyphicon classes with fa_icon helper or fa classes (30 instances)

**Views (HAML):**
| Find | Replace | Files |
|------|---------|-------|
| `glyphicon-chevron-right` | `fa fa-chevron-right` or `fa_icon 'chevron-right'` | `app/views/group_orders/_form.haml:67,129,131,147,149` |
| `glyphicon-tag` / `icon-tag` | `fa fa-tag` or `fa_icon 'tag'` | `app/views/orders/_form.html.haml:37`, `app/views/orders/_articles.html.haml:18`, `app/views/orders/show.html.haml:60`, `app/views/group_orders/_form.html.haml:96` |
| `glyphicon-ok` / `icon-ok` | `fa fa-check` or `fa_icon 'check'` | `app/views/shared/_task_list.haml:29,31`, `app/views/suppliers/_import_search_results.haml:26`, `app/views/articles/create.js.haml:4`, `app/views/articles/destroy.js.haml:6` |
| `glyphicon-question-sign` | `fa fa-question-circle` | `app/views/layouts/application.html.haml:8`, `app/views/shared/_article_fields_units.html.haml:15` |
| `glyphicon-chevron-right` (icon-chevron-right) | `fa fa-chevron-right` | `app/views/articles/migrate_units.html.haml:39` |
| `glyphicon-chevron-left` (icon-chevron-left) | `fa fa-chevron-left` | `app/views/articles/migrate_units.html.haml:41` |
| `glyphicon-remove` | `fa fa-times` | `app/errors/_error.html.haml` |
| `glyphicon` (no suffix) | `fa` | `app/views/group_orders/show.html.haml:68` |

**Ruby helpers:**
| Find | Replace | Location |
|------|---------|----------|
| `glyphicon glyphicon-ok` | `fa fa-check` | `app/helpers/orders_helper.rb:118,142` |
| `glyphicon glyphicon-remove` | `fa fa-times` | `app/helpers/application_helper.rb:115` |

**JavaScript:**
| Find | Replace | Location |
|------|---------|----------|
| `glyphicon-remove-sign` | `fa fa-times-circle` | `app/assets/javascripts/receive-order-form.js:74,77,136` |
| `glyphicon-chevron-*` | `fa fa-chevron-*` | `app/assets/javascripts/article-form.js:12` |
| `glyphicon...` | `fa...` | `app/assets/javascripts/unit-conversion-field.js:27` |
| `glyphicon-*` | `fa fa-*` | `app/inputs/delta_input.rb:34,35` |

### 4-2: Remove glyphicon SCSS references
**File:** `app/assets/stylesheets/bootstrap_and_overrides.css.scss:402,502`

---

## Phase 5 — CSS Cleanup

### 5-1: Remove dead JS file
**Delete:** `app/assets/javascripts/bootstrap.js` (not loaded by any manifest)

### 5-2: Remove manually-defined BS5-native utility classes
**File:** `app/assets/stylesheets/bootstrap_and_overrides.css.scss:649-752`
Remove hand-rolled versions of: `d-flex`, `d-none`, `d-inline-block`, `w-full`, `w-fit-content`, `align-items-center`, `gap-1`, `gap-8`, `text-decoration-none`, `overflow-hidden`, `pt-0`, `pt-5`, `pl-5`
(these are all native to Bootstrap 5 now)

### 5-3: Remove legacy form CSS
**File:** `app/assets/stylesheets/bootstrap_and_overrides.css.scss`
Remove/update rules for:
- `.form-horizontal` (line 41,42,631)
- `.control-group` (line 41,477,480,483,632)
- `.controls` (line 42,497,498,634)
- `.input-prepend` (line 43,574)

### 5-4: Remove legacy panel CSS
**File:** `app/assets/stylesheets/bootstrap_and_overrides.css.scss:579-606`
Remove `.panel`, `.panel-default`, `.panel-heading`, `.panel-body`

### 5-5: Remove pull-left/pull-right fallback
**File:** `app/assets/stylesheets/bootstrap_and_overrides.css.scss:260,263`
Remove `.pull-right { float: right; }` and `.pull-left { float: left; }`

---

## Phase 6 — View-by-View Manual Review

All 135 HAML view files touched by the BS5 migration, grouped by functional area.
Review each file for layout correctness, BS3 remnants, and visual consistency.

**Review priority:** Layouts → Orders → Group Orders → Articles → Finance → Admin → Shared Partials → Plugins

---

## Execution Order

1. **Phase 0A** — Fix modals (broken functionality) ✅
2. **Phase 0B** — Fix tooltips (broken functionality) ✅
3. **Phase 0C** — Fix popovers (broken functionality) ✅
4. **Phase 1** — SimpleForm config (changes all form output) ✅
5. **Phase 2** — Mechanical replacements (safe find-replace) ✅
6. **Phase 3** — Structural component changes ✅
7. **Phase 4** — Icon replacement ✅
8. **Phase 5** — CSS cleanup ✅
9. **Phase 6** — View-by-view manual review (135 files) ← current

Test thoroughly after each phase. Phase 2 can be done as one mechanical pass.
