#!/bin/perl

use Gtk3 -init;

require './configure.pl';
require '../controller/edevices.pl';
require '../controller/ebooks.pl';


use constant COLUMN_DEVICENAME => 0;
use constant COLUMN_DEVICEPATH => 1;
use constant COLUMN_EBOOKNAME => 0;
use constant COLUMN_EBOOKPATH => 1;
use constant COLUMN_EBOOKCONVERTED => 2;
use constant COLUMN_EBOOKCOPIED => 3;


sub show_convert_dialog() {
    # definicion de los elementos
    my $window = Gtk3::Dialog->new ();
    my $vbox = Gtk3::Box->new('vertical', 8);
    my $hbox = Gtk3::Box->new('horizontal', 8);
    my $hbox2 = Gtk3::Box->new('horizontal', 8);
    my $frame1 = Gtk3::Frame->new('Ebooks');
    my $frame2 = Gtk3::Frame->new('Ebook devices');
    my $convert = Gtk3::Button->new('Convert');
    my $copy = Gtk3::Button->new('Copy');
    my $close = Gtk3::Button->new('Close');

    # configurar la ventana
    $window->set_title('Convert ebook');
    $window->set_modal(TRUE);
    $window->set_destroy_with_parent(TRUE);
    $window->set_border_width(8);

    # agregar un contenedor vertical a la ventana
    $window->get_content_area()->add($vbox);

    # meter un contenedor horizontal dentro del contenedor vertical
    $vbox->pack_start($hbox, FALSE, FALSE, 0);
    # meter otro contenedor horizontal dentro del contenedor vertical
    $vbox->pack_start($hbox2, FALSE, FALSE, 0);
    # meter los marcos en el contenedor horizontal
    $hbox->pack_start($frame1, FALSE, FALSE, 0);
    $hbox->pack_start($frame2, FALSE, FALSE, 0);
    # agregar el widget de lista de ebooks
    my $ebooks_lstore = load_ebooks_liststore();
    my $ebooks_treeview = Gtk3::TreeView->new($ebooks_lstore);
    $ebooks_treeview->append_column(
        Gtk3::TreeViewColumn->new_with_attributes(
            'Name', Gtk3::CellRendererText->new, text => COLUMN_EBOOKNAME
        )
    );
    $ebook_treeviewcolumn_path = Gtk3::TreeViewColumn->new_with_attributes(
            'Folder', Gtk3::CellRendererText->new, text => COLUMN_EBOOKPATH
    );
    $ebook_treeviewcolumn_path->set_resizable(TRUE);
    $ebook_treeviewcolumn_path->set_max_width(200);
    $ebooks_treeview->append_column($ebook_treeviewcolumn_path);
    $ebooks_treeview->append_column(
        Gtk3::TreeViewColumn->new_with_attributes(
            'Converted', Gtk3::CellRendererText->new, text => COLUMN_EBOOKCONVERTED
        )
    );
    $ebooks_treeview->append_column(
        Gtk3::TreeViewColumn->new_with_attributes(
            'Copied', Gtk3::CellRendererText->new, text => COLUMN_EBOOKCOPIED
        )
    );
    $frame1->add($ebooks_treeview);
    # agregar el widget de lista de dispositivos
    my $edevices_lstore = load_edevices_liststore();
    my $edevices_treeview = Gtk3::TreeView->new($edevices_lstore);
    $edevices_treeview->append_column(
        Gtk3::TreeViewColumn->new_with_attributes(
            'Device name', Gtk3::CellRendererText->new, text => COLUMN_DEVICENAME
        )
    );
    my $edevice_treeviewcolumn_path = Gtk3::TreeViewColumn->new_with_attributes(
        'Device path', Gtk3::CellRendererText->new, text => COLUMN_DEVICEPATH
    );
    $edevice_treeviewcolumn_path->set_resizable(TRUE);
    $edevice_treeviewcolumn_path->set_max_width(200);
    $edevices_treeview->append_column($edevice_treeviewcolumn_path);
    $frame2->add($edevices_treeview);
    # meter los botones en el contenedor horizontal
    $hbox2->pack_start($convert, FALSE, FALSE, 0);
    $hbox2->pack_start($copy, FALSE, FALSE, 0);
    $hbox2->pack_start($close, FALSE, FALSE, 0);

    # conectar el botón de convert con la acción de convertir
    $convert->signal_connect(clicked => sub { ebook_convert($ebooks_treeview, $window) });
    # conectar el botón de copy con la acción de convertir
    $copy->signal_connect(clicked => sub { ebook_copy($ebooks_treeview, $edevices_treeview, $window) });
    # conectar el botón de quit con la acción de cerrar
    $close->signal_connect(clicked => sub { $window->destroy() });

    # mostrar la ventana
    $window->show_all();
    $window->run;
    $window->destroy;
}

