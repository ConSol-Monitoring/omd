package HTML::Lint::HTML4;

use warnings;
use strict;

use base 'Exporter';
our @EXPORT_OK = qw( %isKnownAttribute %isRequired %isNonrepeatable %isObsolete );

sub _hash   { my %hash; @hash{@_} = (1) x scalar @_; return \%hash; }

our @physical   = qw( b big code i kbd s small strike sub sup tt u xmp );
our @content    = qw( abbr acronym cite code dfn em kbd samp strong var );

our @core   = qw( class id style title );
our @i18n   = qw( dir lang );
our @events = qw( onclick ondblclick onkeydown onkeypress onkeyup
                    onmousedown onmousemove onmouseout onmouseover onmouseup );
our @std    = (@core,@i18n,@events);

our %isRequired = %{_hash( qw( html body head title ) )};
our %isNonrepeatable = %{_hash( qw( html head base title body isindex ))};
our %isObsolete     = %{_hash( qw( listing plaintext xmp ) )};

# Some day I might do something with these.  For now, they're just comments.
sub _ie_only { return @_ };
sub _ns_only { return @_ };

our %isKnownAttribute = (
    # All the physical markup has the same
    (map { $_=>_hash(@std) } (@physical, @content) ),

    a           => _hash( @std, qw( accesskey charset coords href hreflang name onblur onfocus rel rev shape tabindex target type ) ),
    address     => _hash( @std ),
    applet      => _hash( @std ),
    area        => _hash( @std, qw( accesskey alt coords href nohref onblur onfocus shape tabindex target ) ),
    base        => _hash( qw( href target ) ),
    basefont    => _hash( qw( color face id size ) ),
    bdo         => _hash( @core, @i18n ),
    blockquote  => _hash( @std, qw( cite ) ),
    body        => _hash( @std,
                    qw( alink background bgcolor link marginheight marginwidth onload onunload text vlink ),
                    _ie_only( qw( bgproperties leftmargin topmargin ) )
                    ),
    br          => _hash( @core, qw( clear ) ),
    button      => _hash( @std, qw( accesskey disabled name onblur onfocus tabindex type value ) ),
    caption     => _hash( @std, qw( align ) ),
    center      => _hash( @std ),
    cite        => _hash(),
    col         => _hash( @std, qw( align char charoff span valign width ) ),
    colgroup    => _hash( @std, qw( align char charoff span valign width ) ),
    del         => _hash( @std, qw( cite datetime ) ),
    div         => _hash( @std, qw( align ) ),
    dir         => _hash( @std, qw( compact ) ),
    dd          => _hash( @std ),
    dl          => _hash( @std, qw( compact ) ),
    dt          => _hash( @std ),
    embed       => _hash(
                    qw( align height hidden name palette quality play src units width ),
                    _ns_only( qw( border hspace pluginspage type vspace ) ),
                    ),
    fieldset    => _hash( @std ),
    font        => _hash( @core, @i18n, qw( color face size ) ),
    form        => _hash( @std, qw( accept-charset action enctype method name onreset onsubmit target ) ),
    frame       => _hash( @core, qw( frameborder longdesc marginheight marginwidth name noresize scrolling src ) ),
    frameset    => _hash( @core, qw( cols onload onunload rows border bordercolor frameborder framespacing ) ),
    h1          => _hash( @std, qw( align ) ),
    h2          => _hash( @std, qw( align ) ),
    h3          => _hash( @std, qw( align ) ),
    h4          => _hash( @std, qw( align ) ),
    h5          => _hash( @std, qw( align ) ),
    h6          => _hash( @std, qw( align ) ),
    head        => _hash( @i18n, qw( profile ) ),
    hr          => _hash( @core, @events, qw( align noshade size width ) ),
    html        => _hash( @i18n, qw( version xmlns xml:lang ) ),
    iframe      => _hash( @core, qw( align frameborder height longdesc marginheight marginwidth name scrolling src width ) ),
    img         => _hash( @std, qw( align alt border height hspace ismap longdesc name src usemap vspace width ) ),
    input       => _hash( @std, qw( accept accesskey align alt border checked disabled maxlength name onblur onchange onfocus onselect readonly size src tabindex type usemap value ) ),
    ins         => _hash( @std, qw( cite datetime ) ),
    isindex     => _hash( @core, @i18n, qw( prompt ) ),
    label       => _hash( @std, qw( accesskey for onblur onfocus ) ),
    legend      => _hash( @std, qw( accesskey align ) ),
    li          => _hash( @std, qw( type value ) ),
    'link'      => _hash( @std, qw( charset href hreflang media rel rev target type ) ),
    'map'       => _hash( @std, qw( name ) ),
    menu        => _hash( @std, qw( compact ) ),
    meta        => _hash( @i18n, qw( content http-equiv name scheme ) ),
    nobr        => _hash( @std ),
    noframes    => _hash( @std ),
    noscript    => _hash( @std ),
    object      => _hash( @std, qw( align archive border classid codebase codetype data declare height hspace name standby tabindex type usemap vspace width )),
    ol          => _hash( @std, qw( compact start type ) ),
    optgroup    => _hash( @std, qw( disabled label ) ),
    option      => _hash( @std, qw( disabled label selected value ) ),
    p           => _hash( @std, qw( align ) ),
    param       => _hash( qw( id name type value valuetype ) ),
    plaintext   => _hash(),
    pre         => _hash( @std, qw( width ) ),
    q           => _hash( @std, qw( cite ) ),
    script      => _hash( qw( charset defer event for language src type ) ),
    'select'    => _hash( @std, qw( disabled multiple name onblur onchange onfocus size tabindex ) ),
    span        => _hash( @std ),
    style       => _hash( @i18n, qw( media title type ) ),
    table       => _hash( @std,
                    qw( align bgcolor border cellpadding cellspacing datapagesize frame rules summary width ),
                    _ie_only( qw( background bordercolor bordercolordark bordercolorlight ) ),
                    _ns_only( qw( bordercolor cols height hspace vspace ) ),
                    ),
    tbody       => _hash( @std, qw( align char charoff valign ) ),
    td          => _hash( @std,
                    qw( abbr align axis bgcolor char charoff colspan headers height nowrap rowspan scope valign width ),
                    _ie_only( qw( background bordercolor bordercolordark bordercolorlight ) ),
                    ),
    textarea    => _hash( @std, qw( accesskey cols disabled name onblur onchange onfocus onselect readonly rows tabindex wrap ) ),
    th          => _hash( @std,
                    qw( abbr align axis bgcolor char charoff colspan headers height nowrap rowspan scope valign width ),
                    _ie_only( qw( background bordercolor bordercolordark bordercolorlight ) ),
                    ),
    thead       => _hash( @std, qw( align char charoff valign ) ),
    tfoot       => _hash( @std, qw( align char charoff valign ) ),
    title       => _hash( @i18n ),
    tr          => _hash( @std,
                    qw( align bgcolor char charoff valign ),
                    _ie_only( qw( bordercolor bordercolordark bordercolorlight nowrap ) ),
                    _ns_only( qw( nowrap ) ),
                ),
    ul          => _hash( @std, qw( compact type ) ),
);

=for oldobsoletestuffthatIwanttokeep
my %booger = (
    'maybePaired'  => 'LI DT DD P TD TH TR OPTION COLGROUP THEAD TFOOT TBODY COL',

        'expectArgsRE' => 'A|FONT',

        'headTagsRE' => 'TITLE|NEXTID|LINK|BASE|META',

        'requiredContext' =>
        {
        'AREA'     => 'MAP',
        'CAPTION'  => 'TABLE',
        'DD'       => 'DL',
        'DT'       => 'DL',
        'FIELDSET' => 'FORM',
        'FRAME'    => 'FRAMESET',
        'INPUT'    => 'FORM',
        'LABEL'    => 'FORM',
        'LEGEND'   => 'FIELDSET',
        'LI'       => 'DIR|MENU|OL|UL',
        'NOFRAMES' => 'FRAMESET',
        'OPTGROUP' => 'SELECT',
        'OPTION'   => 'SELECT',
        'SELECT'   => 'FORM',
        'TD'       => 'TR',
        'TEXTAREA' => 'FORM',
        'TH'       => 'TR',
        'TR'       => 'TABLE',
        'PARAM'    => 'APPLET|OBJECT',
        },

        'okInHead' =>
                {
                        'ISINDEX' => 1,
                        'TITLE'   => 1,
                        'NEXTID'  => 1,
                        'LINK'    => 1,
                        'BASE'    => 1,
                        'META'    => 1,
                        'RANGE'   => 1,
                        'STYLE'   => 1,
                        'OBJECT'  => 1,
                        '!--'     => 1,
                },


        ## elements which cannot be nested
        'nonNest' => 'A|FORM',

        'requiredAttributes' =>
        {
        APPLET  => 'WIDTH|HEIGHT',
        AREA            => 'ALT',
        BASE            => 'HREF',
        BASEFONT        => 'SIZE',
        BDO             => 'DIR',
        FORM            => 'ACTION',
        IMG             => 'SRC|ALT',
        LINK            => 'HREF',
        MAP             => 'NAME',
        NEXTID  => 'N',
        SELECT  => 'NAME',
        TEXTAREA        => 'NAME|ROWS|COLS'
        },

        'attributeFormat' =>
        {
                'ALIGN',         'BOTTOM|MIDDLE|TOP|LEFT|CENTER|RIGHT|JUSTIFY|'.
                                'BLEEDLEFT|BLEEDRIGHT|DECIMAL',
                'ALINK'          => 'color',
                'BGCOLOR'          => 'color',
                'CLEAR',        'LEFT|RIGHT|ALL|NONE',
                'COLOR'          => 'color',
                'COLS',          '\d+|(\d*[*%]?,)*\s*\d*[*%]?',
                'COLSPAN',         '\d+',
                'DIR'           => 'LTR|RTL',
                'HEIGHT',          '\d+',
                'INDENT',          '\d+',
                'LINK'          => 'color',
                'MAXLENGTH',   '\d+',
                'METHOD',          'GET|POST',
                'ROWS',            '\d+|(\d*[*%]?,)*\s*\d*[*%]?',
                'ROWSPAN',         '\d+',
                'SEQNUM',          '\d+',
                'SIZE',            '[-+]?\d+|\d+,\d+',
                'SKIP',            '\d+',
                'TYPE',            'CHECKBOX|HIDDEN|IMAGE|PASSWORD|RADIO|RESET|'.
                                'SUBMIT|TEXT|[AaIi1]|disc|square|circle|'.
                                'FILE|.*',
                'UNITS',         'PIXELS|EN',
                'VALIGN',        'TOP|MIDDLE|BOTTOM|BASELINE',
                'VLINK'          => 'color',
                'WIDTH',         '\d+%?',
                'WRAP',          'OFF|VIRTUAL|PHYSICAL',
                'X',             '\d+',
                'Y',             '\d+'
        },

        'badTextContext' =>
        {
                'HEAD',  'BODY, or TITLE perhaps',
                'UL',    'LI or LH',
                'OL',    'LI or LH',
                'DL',    'DT or DD',
                'TABLE', 'TD or TH',
                'TR',    'TD or TH'
        },

        'bodyColorAttributes' =>
        [
                qw(BGCOLOR TEXT LINK ALINK VLINK)
        ],

);
=cut

1;

__END__

=head1 NAME

HTML::Lint::HTML4.pm -- Rules for HTML 4 as used by HTML::Lint.

=head1 SYNOPSIS

No user serviceable parts inside.  Used by HTML::Lint.

=head1 SEE ALSO

=over 4

=item HTML::Lint

=back

=head1 AUTHOR

Andy Lester C<andy at petdance.com>

=head1 COPYRIGHT

Copyright (c) Andy Lester 2005. All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
