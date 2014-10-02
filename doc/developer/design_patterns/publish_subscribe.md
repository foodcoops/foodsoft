# Publish/subscribe pattern
## Handling DOM updates after AJAX database manipulation

As an example, let us consider the manipulation (create, update...) of
`StockArticles`. This can be done in different views, e.g.,
`stock_articles/index`, `stock_articles/show` and `deliveries/_form` through
modals using AJAX requests. As an advantage of the AJAX technique, the user
does not need to reload the entire page. However, (after the update of the
`StockArticle` in the database) it is generally required to update the DOM in
the current view such that the page properly reacts to the asynchronous
actions.

The process can be divided in two steps:

1. AJAX database manipulation and
2. DOM updates for the particular view.

The crucial point is the coupling of the two steps since the controller for the
first step offers the same functionality to all views and does not need to know
anything about the current view.


### AJAX database manipulation

**(i)** Example: current view `deliveries/_form` offers a link for the AJAX
  action `StockArticle#new`. This opens a modal filled with
  `stock_articles/_form`.

**(ii)** AJAX form post addresses the `StockArticle#create` action which
  handles the database manipulation.

**(iii)** The database manipulation is finished by the rendering of, e.g.,
  `stock_articles/create.js.erb`. The key task there is to **publish** the
  database changes by calling `trigger`, i.e.,

    $(document).trigger({
      type: 'StockArticle#create',
      stock_article_id: <%= @stock_article.id %>
    });

### DOM updates for the particular view
**(i)** Each view has the opportunity to **subscribe** to particular events
  of the previous step. A very simple example is the update of the
  `stock_articles/index` view after `StockArticle#destroy`:

    $(document).on('StockArticle#destroy', function(e) {
      $('#stockArticle-' + e.stock_article_id).remove();
    });

However, in most of the situations you will like to use the full power of the
MVC framework in order to read new data from the database and render some
partial. Let us consider this slightly more advanced case in the following.

The view `stock_articles/index` could listen (amongst others) to
`StockArticle#create` like this:

    $(document).on('StockArticle#create', function(e) {
      $.ajax({
        url: '#{index_on_stock_article_create_stock_articles_path}',
        type: 'get',
        data: {id: e.stock_article_id},
        contentType: 'application/json; charset=UTF-8'
      });
    });

**(ii)** The action `StockArticles#index_on_stock_article_create` is a special
  helper action to handle DOM updates of the `stock_articles/index` view after
  the creation of a new `StockArticle` with the given `id`.
