use strict;
use warnings;

require '../model/configuration.pm';
use Gtk3;
use Glib 'TRUE', 'FALSE';

use Data::Dumper;

use constant COLUMN_FOLDERNAME => 0;

sub set_efolders_liststore {
    my $lstore = shift;
    my $dataref = shift;

    my @data = @{$dataref};

    for my $efolder (@data) {
        # print $edevice;
        my $iter = $lstore->append; 
        $lstore->set(
            $iter, COLUMN_FOLDERNAME, $efolder
        );
    }
}

sub load_efolders_liststore {
    my $config = new Configuration();
    my $lstore = Gtk3::ListStore->new( 'Glib::String', );
    my @load_result = $config->efolders_load_list();
    if ($load_result[0] == 1) {
        my @data = @{$load_result[1]};
        set_efolders_liststore($lstore, \@data);
    } else {
        return $lstore;
    } 


    return $lstore;
}

sub add_new_efolder {
    my $path = shift;
    my $lstore = shift;
    my $config = new Configuration();
    $config->efolders_load_list();
    my @add_result = $config->efolders_add($path);
    # TODO: COMPROBAR SI HA IDO BIEN Y AGREGAR EL ELEMENTO A LA LISTA
    if ($add_result[0] == 1) {
        # limpiamos el liststore
        $lstore->clear();
        # volvemos a cargar desde memoria de configuración
        my @result_data = @{$add_result[1]};
        set_efolders_liststore($lstore, \@result_data);
        # persistimos
        $config->efolders_save_list();
        # devolvemos ok
        return 1;
    } else {
        # TODO: MANEJAR ERRORES

        # devolvemos mal
        return 0;
    }
}

sub remove_efolder {
    my $treeview = shift;
    my $sel = $treeview->get_selection();
    my ( $model, $iter ) = $sel->get_selected;    
    return unless $iter;

    $model->remove($iter);

    my $config = new Configuration();
    $config->efolders_load_list();
    $config->efolders_remove($model->get_value($iter, COLUMN_FOLDERNAME));
    $config->efolders_save_list();
    
    return 1;
}