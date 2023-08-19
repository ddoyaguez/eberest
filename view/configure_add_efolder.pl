#!/bin/perl

use Gtk3 -init;

sub show_configure_add_efolder_dialog {
    my $lstore = shift;
    # definicion de los elementos
    my $window = Gtk3::Dialog->new ();
    my $vbox = Gtk3::Box->new('vertical', 8);
    my $label_path = Gtk3::Label->new('Path:');
    my $entry_path = Gtk3::Entry->new();
    # my $entry_select = Gtk3::Button->new('Select folder path');
    my $add = Gtk3::Button->new('Add');

    # configurar la ventana
    $window->set_title('Add Ebook folder');
    $window->set_modal(TRUE);
    $window->set_destroy_with_parent(TRUE);
    $window->set_border_width(8);

    # agregar un contenedor vertical a la ventana
    $window->get_content_area()->add($vbox);

    # agregar entrada para ruta de carpetas
    $vbox->pack_start($label_path, FALSE, FALSE, 0);
    $vbox->pack_start($entry_path, FALSE, FALSE, 0);
    # $vbox->pack_start($entry_select, FALSE, FALSE, 0);
    $vbox->pack_start($add, FALSE, FALSE, 0);

    # conectar el botón de agregar dispositivo con la acción de mostrar el dialogo
    $add->signal_connect(clicked => sub { 
        my $path = $entry_path->get_text();
        add_new_efolder($path, $lstore);
        $window->destroy(); 
    });

    # mostrar dialogo
    $window->show_all();
    $window->run;
    $window->destroy;
}

1;