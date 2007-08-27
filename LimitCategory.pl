package MT::Plugin::LimitCategory;
### LimitCategory - Limit the category that each user can post the entry on.
###         Programmed by Piroli YUKARINOMIYA (Open MagicVox.net)
###         @see http://www.magicvox.net/archive/2007/02102342/

use strict;
use LimitCategory qw( load_plugindata );
#use Data::Dumper;#DEBUG

use constant CONFIG_DATA_KEY => 'CategorySetting';

use vars qw( $MYNAME $VERSION );
$MYNAME = 'LimitCategory';
$VERSION = '1.00';

use base qw( MT::Plugin );
my $plugin = new MT::Plugin ({
        name => $MYNAME,
        version => $VERSION,
        author_name => 'Open MagicVox.net',
        author_link => "http://www.magicvox.net/?$MYNAME",
        doc_link => "http://www.magicvox.net/archive/2007/02102342/?$MYNAME",
        description => <<PERLHEREDOC,
Limit the category that each author can post the entry on.
PERLHEREDOC
        config_link => "mt-$MYNAME.cgi",
});
MT->add_plugin ($plugin);

sub instance { $plugin; }



### Register callbacks for 3.3
MT->add_callback ('MT::App::CMS::AppTemplateParam.edit_entry', 1, $plugin, \&edit_entry_edit_param);
sub edit_entry_edit_param {
    my ($cb, $app, $param, $tmpl) = @_;
#
    # Load plugin data and Check setting
    my $config_data = load_plugindata (CONFIG_DATA_KEY) || {};
    sub _checked {
        my ($auth_id, $blog_id, $category_id) = @_;
        return $config_data->{$auth_id}->{$blog_id}->{$category_id}
            if defined $config_data->{$auth_id}
                && defined $config_data->{$auth_id}->{$blog_id}
                && defined $config_data->{$auth_id}->{$blog_id}->{$category_id};
        return 1;
    }

    # Delete the limited category in category list
    my @new_category_loop = ();
    foreach my $category (@{$param->{category_loop}}) {
        if (defined (my $category_id = $category->{category_id})) {
            next unless _checked ($param->{author_id}, $param->{blog_id}, 0 + $category_id);
        }
        push @new_category_loop, $category;
    }

    # Delete the limited category in additional category list
    my @new_add_category_loop = ();
    foreach my $category (@{$param->{add_category_loop}}) {
        if (defined (my $category_id = $category->{category_id})) {
            next unless _checked ($param->{author_id}, $param->{blog_id}, 0 + $category_id);
        }
        push @new_add_category_loop, $category;
    }

    $param->{category_loop} = \@new_category_loop;
    $param->{add_category_loop} = \@new_add_category_loop;
}

1;