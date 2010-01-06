# Ruport

## Introduction

Ruport is a extension that provides Ruport based reporting for Spree.

Basic functionality currently includes 3 types of reports:

 * Product sales report
 * Orders report
 * Total sales report

And export to 3 formats:

 * pdf (Using prawn for pdf generation)
 * csv (only parts of reports can be exported this way due to format's limited functionality)
 * html (with custom overridable template)

With time (and hopefully money) the functionality will be extended
(plans include more reports and export formats like xml and json)

## Credits

Author: Marcin Raczkowski
with contributions from Brian Quinn

Work on original extension was sponsored by [netbird.pl](http://sklep.netbird.pl)

## Basic usage

### Instalation

For git users:
<code>git submodule add git://github.com/swistak/spree-ruport.git vendor/extensions/ruport</code>

for others (or git users that don't like submodules):
<code>ruby script/extension install git://github.com/swistak/spree-ruport.git</code>

### Customization

You can set logo for pdf reports with
<code>Spree::Config.set(:pdf_logo => '/images/admin/bg/spree_logo_pdf.png')</code>
in your migration.

*WARNING* prawn expects image will have proper _dpi_ (72 by default) othervise
your image will be incorrectly enlarged, and will look ugly and pixelated.

# Contributing

## Introduction

I'll gladly include more report types and output formats, but remember to:

 * Read documentation of proper classes, and this readme.
 * Check if report type would be usefull to public.
 * Check if report isn't tied to your extension functionality (will it work without it?)
 * Write unit tests
 * Commit changes in clear path sets (before submiting pull request,
   you can rebase your changes into separate branch)

If your report type is tied to your extension functionality you can include it in your own extension.
More on how to do it bellow.

If you plan on introducing new features here's the TODO:

 * Optional generation of monthly reports when month ends with _whenever_
 * Generating report once, saving to file, and later serving it from file

## Creating new report types

When creating new reports you have to provide two classes:

 * Model (in app/models)
 * Ruport Controller (in app/reports)

### Model

Model should inherit from _Report_ and provide preferences needed to generate
the report.

Model is usually empty, but if your report requires special parameters you can
use the preferences system to add typed attributes to your model, they'll be
automatically available in your report controller (the'll be merged with
attributes into #options)

### Controller

Controller should be named exactly like model, but with Controller
suffix and inherit from _BaseRuportController_

*WARNING!* Controller is not a standard rails controller, instead it's _Ruport_
controller and all conventions and options of ruport controller apply.

If you need help understanding how it works, please read http://ruportbook.com
especialy:

 * http://ruportbook.com/data_manipulations.html
 * http://ruportbook.com/payr_formatting_1.html

Default formatters provided with ruport extension are customized version
of ruport formaters, adjusted for spree.
In case of pdf formatter it was completelly rewritten to support prawn instead of pdf::writer

Default formatters provide following stages:

 * header
 * body
 * summary
 * footer

## Providing reports in your extensions

If you're providing a report in your own extension (it's tied to extension functionality)
there are few things you need to consider.

Since ruport extension might not be available you need to add guards to your models and controllers
for model

  <code>if defined?(Report)
    # your model code here
  end</code>

for controller

  <code>if defined?(BaseRuportController)
    # Controller code here
  end</code>

In your extension #activate method you also need to activate report by adding it to
Report::AVAILABLE_REPORTS set.

  <code>Report::AVAILABLE_REPORTS.add(MyCustomReport)</code>

Then you have to decide if you want to use default formaters or custom ones.
If you choose custome ones you have to provide them for pdf, html, and csv.
If you choose default ones, you have to select them for rendering your report with:

  <code>
  Formatter::Pdf.renders  :pdf,  :for => MyCustomReport
  Formatter::Html.renders :html, :for => MyCustomReport
  Formatter::Csv.renders  :csv,  :for => MyCustomReport
  </code>