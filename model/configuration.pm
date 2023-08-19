package Configuration;

use strict;

use File::FnMatch qw(:fnmatch);



# constructor de la clase
sub new {
    my $class = shift;
    my $self = {};
    $self->{'EFOLDERS'} = [];
    $self->{'EFOLDERS_FNAME'} = 'folders.conf';
    $self->{'EDEVICES'} = {};
    $self->{'EDEVICES_FNAME'} = 'devices.conf';
    $self->{'EBOOKS'} = {};

    bless $self, $class;
    return $self;
}

# ver o cambiar el fichero con el listado de carpetas
sub efolders_fname {
    my $self = shift;
    $self->{'EFOLDERS_FNAME'} = shift if (@_);
    return $self->{'EFOLDERS_FNAME'};
}

# cargar listado de carpetas
sub efolders_load_list {
    my $self = shift;
    if (open(FILE, '<', $self->{'EFOLDERS_FNAME'})) {
        $self->{'EFOLDERS'} = [];
        while(<FILE>) {
            chomp($_);
            push((@{$self->{'EFOLDERS'}}, $_));
        }
        close(FILE);
        return (1, $self->{'EFOLDERS'});
    } else {
        return (0, $!);
    }
}

# guardar listado de carpetas
sub efolders_save_list {
    my $self = shift;
    if (open(FILE, '>', $self->{'EFOLDERS_FNAME'})) {
        foreach my $efolder (@{$self->{'EFOLDERS'}}) {
            print FILE $efolder . "\n";
        }
        close(FILE);
        return (1, scalar((@{$self->{'EFOLDERS'}})));
    } else {
        return (0, $!);
    }
}

# agregar una carpeta al listado
sub efolders_add {
    my $self = shift;
    my $efolder = shift;

    # si ya existe entonces mejor no lo añadimos
    if (grep {$efolder eq $_} (@{$self->{'EFOLDERS'}})) {
        return (0, $self->{'EFOLDERS'});
    }

    push((@{$self->{'EFOLDERS'}}), $efolder);
    return (1, $self->{'EFOLDERS'});
}

# eliminar una carpeta del listado
sub efolders_remove {
    my $self = shift;
    my $efolder = shift;

    $self->{'EFOLDERS'} = grep {$efolder eq $_} (@{$self->['EFOLDERS']});

    return (1, $self->['EFOLDERS']);
}

# ver o cambiar el fichero con el listado de dispositivos
sub edevices_fname {
    my $self = shift;
    $self->{'EDEVICES_FNAME'} = shift if (@_);
    return $self->{'EDEVICES_FNAME'};
}

# cargar listado de dispositivos
sub edevices_load_list {
    my $self = shift;
    if (open(FILE, '<', $self->{'EDEVICES_FNAME'})) {
        $self->{'EDEVICES'} = {};
        while(<FILE>) {
            chomp($_);
            my (@splt) = split(/,/, $_);
            $self->{'EDEVICES'}->{@splt[0]} = @splt[1];
        }
        close(FILE);
        return (1, $self->{'EDEVICES'});
    } else {
        return (0, $!);
    }
}

# guardar listado de dispositivos
sub edevices_save_list {
    my $self = shift;
    if (open(FILE, '>', $self->{'EDEVICES_FNAME'})) {
        foreach my $edevice (keys (%{$self->{'EDEVICES'}})) {
            print FILE $edevice . "," . $self->{'EDEVICES'}{$edevice} . "\n";
        }
        close(FILE);
        return (1, scalar(keys (%{$self->{'EDEVICES'}})));
    } else {
        return (0, $!);
    }
}

# agregar un dispositivo al listado
sub edevices_add {
    my $self = shift;
    my $edevice_name = shift;
    my $edevice_path = shift;
    $self->{'EDEVICES'}->{$edevice_name} = $edevice_path;
    return (1, $self->{'EDEVICES'});
}

# eliminar un dispositivo del listado
sub edevices_remove {
    my $self = shift;
    my $edevice = shift;

    delete($self->{'EDEVICES'}->{$edevice});

    return (1, $self->{'EDEVICES'});
}

# componer el listado de ebooks a partir de la lista de carpetas
sub ebooks_search {
    my $self = shift;
    # escanear las carpetas usando el metodo
    # https://metacpan.org/pod/File::FnMatch
    # https://metacpan.org/release/NWCLARK/perl-5.8.9/view/lib/File/Find.pm
    # recorremos las carpetas
    foreach my $efolder (@{$self->{'EFOLDERS'}}) {
        # abrimos carpeta
        opendir (DIR, $efolder);
        # recorremos listado de ficheros epub y los metemos en el hash sin extension
        # print "directory $efolder opened\n";
        foreach my $ebook (grep { fnmatch("*.epub", $_) } readdir DIR) {
            # quitamos extension
            # print "found ebook $ebook\n";
            my @ebook_splitted = split(/\./, $ebook);
            my $ebook_name = $ebook_splitted[0];
            # print "ebook name $ebook_name\n";
            # metemos clave el nombre sin extension
            # metemos valor el directorio
            # metemos valor marca de que no está convertido a prc
            # metemos valor marca de que no está traspasado a un ebook
            $self->{'EBOOKS'}->{$ebook_name} = [$efolder, 0, 0];
        }
        # cerramos
        closedir DIR;
    }

    # recorremos el hash de ebooks
    foreach my $ebook (keys (%{$self->{'EBOOKS'}})) {
        # sacamos directorio que lo contiene
        my $efolder = $self->{'EBOOKS'}->{$ebook}[0];
        # sacamos el nombre de fichero con extension prc
        my $ebook_prc = $ebook . ".prc";
        # sacamos la ruta completa de fichero con extension prc
        my $ebook_prc_full_path = $efolder . "/" . $ebook_prc;
        # si existe entonces ya está convertido
        if (-e $ebook_prc_full_path) {
            $self->{'EBOOKS'}->{$ebook}[1] = 1;
        }
        # recorremos los dispositivos
        foreach my $edevice (keys (%{$self->{'EDEVICES'}})) {
            my $edevice_path = $self->{'EDEVICES'}->{$edevice};
            $ebook_prc_full_path = $edevice_path . "/" . $ebook_prc;
            # si existe ese fichero en el dispositivo entonces lo marcamos como que ya está transferido
            if (-e $ebook_prc_full_path) {
                $self->{'EBOOKS'}->{$ebook}[2] = 1;
            }
        }
    }

    return (1, $self->{'EBOOKS'});
}

1;