FoodsoftPickup
==============

API endpoint for an app that tells members which of their group orders are
waiting to be picked up.

Foodsoft has the data for this (`Order#pickup`, and `PickupsController#index`
for the web) but no API for it, so an app had to read the web UI instead. This
plugin adds one small endpoint.

* `GET /:foodcoop/pickup/group_orders` -- the group orders of the ordergroup of
  the user holding the token, with the articles that ordergroup ordered, the
  pickup date, and the note for the people picking up.

Authentication
--------------

Plain doorkeeper bearer tokens, like every other endpoint in foodsoft. An app
registers an application under `/oauth/applications`, the user authorizes it,
and the app calls the endpoint with `Authorization: Bearer <token>`.

The token needs the `group_orders:user` scope, which
`Concerns::AuthApi#doorkeeper_scope_permitted?` maps to `User#role_orders?` or
membership of an ordergroup -- i.e. any member. There is no `ordergroup_id`
parameter: the endpoint is always about the caller's own ordergroup, so a
member token cannot be used to read other ordergroups and no elevated
`orders` role is required.

Enable per foodcoop with `use_pickup: true` in the application config; it is
off by default because it adds an API surface.

Why a plugin rather than the core API?
--------------------------------------

Upstream removed the pickup app and its API from the core README (2020) and
has no capacity for a new API surface plus the clients that would depend on
it. As a plugin it can ship to the foodcoops that want it without asking
upstream to maintain an app-facing contract, and the endpoint can be changed
freely while the app is being built -- there is no v1/v2 story here, because
a plugin does not promise stability to third-party clients.

Out of scope
------------

Recording what actually arrived (`GroupOrderArticle#result`) -- the "receive"
or distribute side -- is not part of this plugin. It writes core state, needs
the `orders` role, and overlaps with the receive screen that the
`current_orders` plugin already has in the web UI. It should be looked at
separately, ideally together with `current_orders`.

Maintainers
-----------

* Martin Ortbauer (foodcoopsat) -- https://github.com/foodcoopsat/foodsoft
