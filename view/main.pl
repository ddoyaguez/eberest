#!/bin/perl

# ejemplo: https://github.com/dave-theunsub/gtk3-perl-demos/blob/master/dialog_boxes.pl

use Gtk3 -init;

require './convert.pl';
require './configure.pl';

# definicion de los elementos
my $window = Gtk3::Window->new ('toplevel');
my $vbox = Gtk3::Box->new('vertical', 8);
my $hbox = Gtk3::Box->new('horizontal', 8);
my $convert = Gtk3::Button->new('Convert');
my $configure = Gtk3::Button->new('Configure');
my $quit = Gtk3::Button->new('Quit');
my $logo = Gtk3::Image->new();

# configurar la ventana
$window->set_title('Eberest');
$window->set_border_width(8);

# cargar el logo
$logo->set_from_file ('../img/eberest_logo.png');

# agregar un contenedor vertical a la ventana
$window->add($vbox);

# meter el logo en el contenedor vertical
$vbox->pack_start($logo, FALSE, FALSE, 0);
# meter un contenedor horizontal dentro del contenedor vertical
$vbox->pack_start($hbox, FALSE, FALSE, 0);
# meter los botones en el contenedor horizontal
$hbox->pack_start($convert, FALSE, FALSE, 0);
$hbox->pack_start($configure, FALSE, FALSE, 0);
$hbox->pack_start($quit, FALSE, FALSE, 0);

# conectar el botón de convertir con la acción de mostrar el cuadro de convertir
$convert->signal_connect(clicked => sub { show_convert_dialog() });
# conectar el botón de configurar con la acción de mostrar el cuadro de configurar
$configure->signal_connect(clicked => sub { show_configure_dialog() });
# conectar el botón de quitar con la acción de cerrar
$quit->signal_connect(clicked => sub { Gtk3::main_quit });

# mostrar la ventana
$window->show_all();

# bucle principal
Gtk3::main();
