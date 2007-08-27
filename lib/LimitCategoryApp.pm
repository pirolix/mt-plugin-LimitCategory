package LimitCategoryApp;
### LimitCategory - Limit the category that each user can post the entry on.
###         Programmed by Piroli YUKARINOMIYA (Open MagicVox.net)

use strict;
use LimitCategory qw( save_plugindata load_plugindata set_lexicons );
use MT::I18N;
#use Data::Dumper;#DEBUG

use constant CONFIG_DATA_KEY => 'CategorySetting';

use base qw( MT::App::CMS );
sub init {
    my $app = shift;
#
    $app->SUPER::init (@_)
        or return;
    $app->add_methods (
            config => \&page_config,
            config_save => \&page_config_save,
            about => \&page_about,
    );
    $app->{'default_mode'} = 'config';
    $app;
}

sub build_page {
    my ($app, $page, $param) = @_;
    my $q = $app->{'query'};
#
    $param->{'saved'} = $q->param('saved');
    $app->SUPER::build_page (MT::Plugin::LimitCategory->instance->load_tmpl ($page), $param);
}

########################################################################
### Basically Configuration
sub page_config {
    my $app = shift;
    my $q = $app->{query};
#
    my $param = {};
    set_lexicons ($param);
    $param->{TAB_CONFIG} = 1;

    # Check if admin user is
    my $login_auth = $app->{author};
    $param->{IS_ADMIN_USER} = 1
        if $login_auth->is_superuser;

    # Setting about current author
    my $config_auth_id = $q->param ('author_id') || 1;
    $param->{AUTHORID} = $config_auth_id;

    # Enumerate all authors
    require MT::Author;
    my @authors = ();
    my $auth_iter = MT::Author->load_iter ({ type => MT::Author::AUTHOR() }, { sort => 'name' });
    while (my $author = $auth_iter->()) {
        push @authors, {
                id => $author->id,
                name => $author->name,
                selected => ($author->id == $config_auth_id ? 1 : 0), };
    }

    # Load plugin data
    my $config_data = load_plugindata (CONFIG_DATA_KEY) || {};
    sub _checked {
        my ($auth_id, $blog_id, $category_id) = @_;
        return $config_data->{$auth_id}->{$blog_id}->{$category_id}
            if defined $config_data->{$auth_id}
                && defined $config_data->{$auth_id}->{$blog_id}
                && defined $config_data->{$auth_id}->{$blog_id}->{$category_id};
        return 1;
    }

    ### Recursively called function to buikd categories tree
    my $_enumCategories_count;
    my $_enumCategories_level = -1;
    sub _enumCategories {
        my ($blog_id, $result, $category) = @_;
        $_enumCategories_level++;
        push @$result, {
                blog_id => $blog_id,
                id => $category->id,
                label => '&nbsp;' x ($_enumCategories_level * 4). $category->label,
                description => $category->description,
                odd => $_enumCategories_count++ % 2,
                checked => &_checked ($config_auth_id, $blog_id, $category->id) };
        foreach my $child_category ($category->children_categories) {
            _enumCategories ($blog_id, $result, $child_category);
        }
        $_enumCategories_level--;
    };

    # Enumerate the blogs that current setting author can post on
    require MT::Permission;
    require MT::Blog;
    my @blogs = ();
    my $blog_count = 0;
    for my $perms (MT::Permission->load ({ author_id => $config_auth_id })) {
        my $blog = MT::Blog->load ($perms->blog_id);
        next unless $perms->can_post;
        my @categories = ();
        $_enumCategories_count = 1;
        #
        push @categories, {
                blog_id => $blog->id,
                id => 0,
                label => '<MT_TRANS phrase="(Unlabeled category)">',
                description => '',
                odd => $_enumCategories_count++ % 2,
                checked => &_checked ($config_auth_id, $blog->id, 0) };
        #
        foreach my $category (MT::Category->top_level_categories ($blog->id)) {
            _enumCategories ($blog->id, \@categories, $category);
        }
        push @blogs, { id => $blog->id, name => $blog->name, category => \@categories };
    }

    $param->{AUTHORS} = \@authors;
    $param->{BLOGS} = \@blogs;
    $app->add_breadcrumb ($param->{MYNAME});
    $app->add_breadcrumb ($param->{TAB_TITLE_CONFIG});
    return $app->build_page ('config_basic.tmpl', $param);
}

### Saving
sub page_config_save {
    my $app = shift;
    my $q = $app->{query};
    my $login_auth = $app->{author};
#
    # Check if admin user is
    $login_auth->is_superuser
        or goto EXIT_CONFIG_SAVE;
    # Check if author exists
    my $config_auth_id = $q->param ('author_id')
        or goto EXIT_CONFIG_SAVE;
    my $author = MT::Author->load ({ id => $config_auth_id })
        or goto EXIT_CONFIG_SAVE;

    # Load plugin data
    my $config_data = load_plugindata (CONFIG_DATA_KEY) || {};

    # Enumes blogs
    for my $perms (MT::Permission->load ({ author_id => $config_auth_id })) {
        my $blog = MT::Blog->load ($perms->blog_id);
        next unless $perms->can_post;
        # Enumes categories on blog
        foreach my $category (MT::Category->load ({ blog_id => $blog->id })) {
            $config_data->{$config_auth_id}->{$blog->id}->{$category->id}
                    = defined $q->param ($blog->id. '_'. $category->id) ? 1 : 0;
        }
        $config_data->{$config_auth_id}->{$blog->id}->{0}
                = defined $q->param ($blog->id. '_0') ? 1 : 0;
    }

    # Write back plugin data
    save_plugindata (CONFIG_DATA_KEY, $config_data);

EXIT_CONFIG_SAVE:
    return $app->page_config;
}

### About this plugin
sub page_about {
    my $app = shift;
#
    my $param = {};
    set_lexicons ($param);
    $param->{TAB_ABOUT} = 1;

    $app->add_breadcrumb ($param->{MYNAME});
    $app->add_breadcrumb ($param->{TAB_TITLE_ABOUT});
    return $app->build_page ('config_about.tmpl', $param);
}

1;