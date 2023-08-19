use strict;
use warnings;

use Data::Dumper;

require '../model/configuration.pm';
use Gtk3;
use Glib 'TRUE', 'FALSE';

use constant COLUMN_EBOOKNAME => 0;
use constant COLUMN_EBOOKPATH => 1;
use constant COLUMN_EBOOKCONVERTED => 2;
use constant COLUMN_EBOOKCOPIED => 3;
use constant COLUMN_DEVICENAME => 0;
use constant COLUMN_DEVICEPATH => 1;

sub set_ebooks_liststore {
    my $lstore = shift;
    my $dataref = shift;

    my %data = %{$dataref};

    for my $ebook (keys %data) {
        # print $edevice;
        my $iter = $lstore->append; 
        my $converted = undef;
        my $copied = undef;
        if ($data{$ebook}[1] == 1) {
            $converted = "Yes";
        } else {
            $converted = "No";
        }
        if ($data{$ebook}[2] == 1) {
            $copied = "Yes";
        } else {
            $copied = "No";
        }
        $lstore->set(
            $iter, COLUMN_EBOOKNAME, $ebook, 
                   COLUMN_EBOOKPATH, $data{$ebook}[0],
                   COLUMN_EBOOKCONVERTED, $converted,
                   COLUMN_EBOOKCOPIED, $copied
        );
    }

}

sub load_ebooks_liststore {
    my $config = new Configuration();
    my $lstore = Gtk3::ListStore->new( 'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String');
    $config->efolders_load_list();
    $config->edevices_load_list();
    # print "----- BEGIN config -----\n";
    # print Dumper $config;
    # print "-----  END  config -----\n";
    my @search_result = $config->ebooks_search();
    # print "----- BEGIN scalar(keys SEARCH_RESULT[1]) -----\n";
    # print Dumper scalar(keys %{$search_result[1]});
    # print "-----  END  scalar(keys SEARCH_RESULT[1]) -----\n";
    if (scalar(keys %{$search_result[1]}) > 0) {
        my %ebooks_data = %{$search_result[1]};
        my $ebooks_data_ref = \%ebooks_data;
        # print Dumper %ebooks_data;
        set_ebooks_liststore($lstore, $ebooks_data_ref);
        # print "load_ebooks_liststore returning filled liststore\n";
    }
    return $lstore;
}

sub ebook_convert {
    my $ebook_treeview = shift;
    my $window = shift;
    my $sel = $ebook_treeview->get_selection();
    my ( $model, $iter ) = $sel->get_selected;
    if ($iter == undef) {
        return 0;
    }
    my $ebook_name = $model->get_value($iter, COLUMN_EBOOKNAME);
    my $ebook_folder = $model->get_value($iter, COLUMN_EBOOKPATH);
    # print "----- BEGIN ebook_folder -----\n";
    # print Dumper $ebook_folder;
    # print "-----  END  ebook_folder -----\n";
    system("../kindlegen_linux_2.6_i386_v2_9/kindlegen " . $ebook_folder . "/" . $ebook_name . ".epub -o " . $ebook_name . ".prc");
    $window->destroy;
    return 1;
}

sub ebook_copy {
    my $ebook_treeview = shift;
    my $edevice_treeview = shift;
    my $window = shift;
    my $config = new Configuration();
    $config->edevices_load_list();
    my $sel = $ebook_treeview->get_selection();
    my ( $model, $iter ) = $sel->get_selected;
    if (!$iter) {
        return 0;
    }
    my $ebook_name = $model->get_value($iter, COLUMN_EBOOKNAME);
    my $ebook_folder = $model->get_value($iter, COLUMN_EBOOKPATH);
    my $edevice_name = undef;
    my $edevice_folder = undef;
    # print "Edevices: ". scalar(keys %{$config->{'EDEVICES'}}). "\n";
    if (scalar(keys %{$config->{'EDEVICES'}}) == 1) {
        # $edevice_name = (keys %{$config->{'EDEVICES'}})[0];
        ($edevice_name) = keys %{$config->{'EDEVICES'}};
        $edevice_folder = $config->{'EDEVICES'}->{$edevice_name};
    } else {
        my $edevsel = $edevice_treeview->get_selection();
        my ( $edev_model, $edev_iter ) = $edevsel->get_selected;
        $edevice_name = $edev_model->get_value($iter, COLUMN_DEVICENAME);
        $edevice_folder = $edev_model->get_value($iter, COLUMN_DEVICEPATH);
    }
    # print "cp $ebook_folder/$ebook_name.prc $edevice_folder/$ebook_name.prc";
    system("cp $ebook_folder/$ebook_name.prc $edevice_folder/$ebook_name.prc");
    $window->destroy;
    return 1;
}