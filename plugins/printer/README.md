FoodsoftPrinter
=================

This plugin adds a printer queue to allow mebers to print PDF with one click.
Usually a mini computer with a printer at a room in the foodcoop will wait for
new printer jobs and prints them.

This plugin is not enabled by default. To install it, add uncomment the
corresponding line in the `Gemfile`, or add:

```Gemfile
gem 'foodsoft_printer', path: 'plugins/foodsoft_printer'
```

This plugin introduces the foodcoop config option `printer_token`, which takes
a random string for authentication at the endpoint. Additionally a set of
PDF files can be selected, which will be generated when a print is triggered.

The communication with the printer client happens via two endpoints, which both
require the `printer_token` as `Bearer` token in the `Authorization` header.
* `/:foodcoop/printer/socket`: main WebSocket communication
* `/:foodcoop/printer/:id`: HTTP GET for documents

The main communication happens via JSON messages via an WebSocket connection,
which sends an array of docuement ids to the client, which need to be printed.
Addionally the docuemnt can be downloaded as PDF via a separate endpoint.
The client can updated the status of the documents by sending an object with
the following keys to the server:
* `id` (NBR, REQUIRED): id of the document, which should be updated
* `state` (ENUM): the current sate of the printing progress.
* `message` (STR, REQUIRES `state`): detailed description of the current state
                                     (e.g. download progress)
* `finish` (BOOL): when set to `true` the job will be marked as done

The following values are valid for the `state` property:
* `queued`: the document is not yet ready for printing
* `ready`: the document is ready to be downloaded
* `downloading`: transfer of the document is in progress
* `pending`: download completed, waiting for the printer
* `held`: e.g., for "PIN printing"
* `processing`: printing is in progress
* `stopped`: out of paper, etc.)
* `cancelled`: the user stopped the action
* `aborted`: the printer stopped the action
* `completed`: print was successful

**Example**:
A server sending `{"unfinished_jobs":[12,16]}` via WebSocket indicates that the
two documents `12` and `16` are ready for printing. The client will request the
first document from `/foodcoop/printer/12` and send it to the printer. The
status can be updated by sending `{"id":12,"state":"pending"}` via WebSocket to
the server. Sending `{"id":12,"state":"completed","finish":true}` as soon as
when the printing succeded will mark the job done.

To use this plugin the webserver must support WebSockets. The current
implementation uses socket hijack, which is not supported by `thin`. `puma`
supports that, but might lead to other problems, since it's not well tested
in combination with foodsoft. Please be careful when switching the webserver!

This plugin is part of the foodsoft package and uses the AGPL-3 license (see
foodsoft's LICENSE for the full license text).
