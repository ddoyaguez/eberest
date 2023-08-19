use strict;
use warnings;

require '../model/configuration.pm';
use Gtk3;
use Glib 'TRUE', 'FALSE';

# ejemplo: https://github.com/dave-theunsub/gtk3-perl-demos/blob/master/liststore.pl

use constant COLUMN_DEVICENAME => 0;
use constant COLUMN_DEVICEPATH => 1;

sub set_edevices_liststore {
    my $lstore = shift;
    my $dataref = shift;

    my %data = %{$dataref};

    for my $edevice (keys %data) {
        # print $edevice;
        my $iter = $lstore->append; 
        $lstore->set(
            $iter, COLUMN_DEVICENAME, $edevice, COLUMN_DEVICEPATH, $data{$edevice}
        );
    }
}

sub load_edevices_liststore {
    my $config = new Configuration();
    my $lstore = Gtk3::ListStore->new( 'Glib::String', 'Glib::String', );
    my @load_result = $config->edevices_load_list();
    if ($load_result[0] == 1) {
        my %data = %{$load_result[1]};
        set_edevices_liststore($lstore, \%data);
    } else {
        return $lstore;
    } 


    return $lstore;
}

sub add_new_edevice {
    my $name = shift;
    my $path = shift;
    my $lstore = shift;
    # print "Name: ". $name . "\n"; 
    # print "Path: ". $path . "\n"; 
    my $config = new Configuration();
    $config->edevices_load_list();
    my @add_result = $config->edevices_add($name, $path);
    # TODO: COMPROBAR SI HA IDO BIEN Y AGREGAR EL ELEMENTO A LA LISTA
    if ($add_result[0] == 1) {
        # limpiamos el liststore
        $lstore->clear();
        # volvemos a cargar desde memoria de configuración
        my %result_data = %{$add_result[1]};
        set_edevices_liststore($lstore, \%result_data);
        # persistimos
        $config->edevices_save_list();
        # devolvemos ok
        return 1;
    } else {
        # TODO: MANEJAR ERRORES

        # devolvemos mal
        return 0;
    }
}

sub remove_edevice {
    my $treeview = shift;
    my $sel = $treeview->get_selection();
    my ( $model, $iter ) = $sel->get_selected;    
    return unless $iter;

    $model->remove($iter);

    my $config = new Configuration();
    $config->edevices_load_list();
    $config->edevices_remove($model->get_value($iter, COLUMN_DEVICENAME));
    $config->edevices_save_list();
    
    return 1;
}

1;