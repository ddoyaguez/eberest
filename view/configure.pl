#!/bin/perl

# ejemplo: https://github.com/dave-theunsub/gtk3-perl-demos/blob/master/basic-liststore.pl

use Gtk3 -init;

require '../controller/edevices.pl';
require '../controller/efolders.pl';
require './configure_add_ebook.pl';
require './configure_add_efolder.pl';

use constant COLUMN_DEVICENAME => 0;
use constant COLUMN_DEVICEPATH => 1;
use constant COLUMN_FOLDERPATH => 0;

sub show_configure_dialog {
    # definicion de los elementos
    my $window = Gtk3::Dialog->new ();
    my $vbox = Gtk3::Box->new('vertical', 8);
    my $hbox = Gtk3::Box->new('horizontal', 8);
    my $frame1 = Gtk3::Frame->new('Ebook folders');
    my $frame2 = Gtk3::Frame->new('Ebook devices');
    my $vbox1 = Gtk3::Box->new('vertical', 8);
    my $vbox2 = Gtk3::Box->new('vertical', 8);
    my $hbox1 = Gtk3::Box->new('horizontal', 8);
    my $hbox2 = Gtk3::Box->new('horizontal', 8);
    my $add_efolder = Gtk3::Button->new('Add');
    my $rem_efolder = Gtk3::Button->new('Remove');
    my $add_edevice = Gtk3::Button->new('Add');
    my $rem_edevice = Gtk3::Button->new('Remove');
    my $convert = Gtk3::Button->new('Convert');
    my $configure = Gtk3::Button->new('Configure');
    my $close = Gtk3::Button->new('Close');

    # configurar la ventana
    $window->set_title('Eberest configuration');
    $window->set_modal(TRUE);
    $window->set_destroy_with_parent(TRUE);
    $window->set_border_width(8);

    # agregar un contenedor vertical a la ventana
    $window->get_content_area()->add($vbox);

    # agregar un contenedor horizontal al contenedor vertical
    $vbox->pack_start($hbox, FALSE, FALSE, 0);
    # agregar el boton de cerrar en el contenedor vertical
    $vbox->pack_start($close, FALSE, FALSE, 0);
    # agregar un contenedor vertical dentro del primer marco
    $frame1->add($vbox1);
    # agregar elementos dentro del primer contenedor vertical
    # TODO: AGREGAR COSAS AL PRIMER CONTENEDOR
    my $efolders_lstore = load_efolders_liststore();
    my $efolders_treeview = Gtk3::TreeView->new($efolders_lstore);
    $efolders_treeview->append_column(
        Gtk3::TreeViewColumn->new_with_attributes(
            'Folder path', Gtk3::CellRendererText->new, text => COLUMN_FOLDERPATH
        )
    );
    # agregar botones dentro del primer contenedor horizontal
    $hbox1->pack_start($add_efolder, FALSE, FALSE, 0);
    $hbox1->pack_start($rem_efolder, FALSE, FALSE, 0);
    # agregar elementos dentro del segundo contenedor vertical
    $vbox1->pack_start($efolders_treeview, FALSE, FALSE, 0);
    $vbox1->pack_start($hbox1, FALSE, FALSE, 0);
    # agregar un contenedor vertical dentro del segundo marco
    $frame2->add($vbox2);
    # agregar el widget de lista de dispositivos
    my $edevices_lstore = load_edevices_liststore();
    my $edevices_treeview = Gtk3::TreeView->new($edevices_lstore);
    $edevices_treeview->append_column(
        Gtk3::TreeViewColumn->new_with_attributes(
            'Device name', Gtk3::CellRendererText->new, text => COLUMN_DEVICENAME
        )
    );
    $edevices_treeview->append_column(
        Gtk3::TreeViewColumn->new_with_attributes(
            'Device path', Gtk3::CellRendererText->new, text => COLUMN_DEVICEPATH
        )
    );
    # agregar botones dentro del segundo contenedor horizontal
    $hbox2->pack_start($add_edevice, FALSE, FALSE, 0);
    $hbox2->pack_start($rem_edevice, FALSE, FALSE, 0);
    # agregar elementos dentro del segundo contenedor vertical
    $vbox2->pack_start($edevices_treeview, FALSE, FALSE, 0);
    $vbox2->pack_start($hbox2, FALSE, FALSE, 0);
    # agregar el primer marco dentro del contenedor vertical
    $hbox->pack_start($frame1, FALSE, FALSE, 0);
    $hbox->pack_start($frame2, FALSE, FALSE, 0);

    # conectar el botón de quit con la acción de cerrar
    $close->signal_connect(clicked => sub { $window->destroy() });
    # conectar el botón de agregar carpeta con la acción de mostrar el dialogo
    $add_efolder->signal_connect(clicked => sub { show_configure_add_efolder_dialog($efolders_lstore) });
    # conectar el botón de eliminar carpeta con la acción de eliminar
    $rem_efolder->signal_connect(clicked => sub { remove_efolder($efolders_treeview) });
    # conectar el botón de agregar dispositivo con la acción de mostrar el dialogo
    $add_edevice->signal_connect(clicked => sub { show_configure_add_edevice_dialog($edevices_lstore) });
    # conectar el botón de eliminar dispositivo con la acción de eliminar
    $rem_edevice->signal_connect(clicked => sub { remove_edevice($edevices_treeview) });

    # mostrar la ventana
    $window->show_all();
    $window->run;
    $window->destroy;
}

1;