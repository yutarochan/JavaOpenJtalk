#!/usr/bin/perl -X

make_htsvoice($ARGV[0], $ARGV[1]);

# sub routine for getting stream name for HTS voice
sub get_stream_name($) {
   my ($from) = @_;
   my ($to);

   if ( $from eq 'mgc' ) {
      if ( $gm == 0 ) {
         $to = "MCP";
      }
      else {
         $to = "LSP";
      }
   }
   else {
      $to = uc $from;
   }

   return $to;
}

# sub routine for getting file size
sub get_file_size($) {
   my ($file) = @_;
   my ($file_size);

   $file_size = `$WC -c < $file`;
   chomp($file_size);

   return $file_size;
}

sub make_htsvoice($$) {
   my ( $voicedir, $voicename ) = @_;
   my ( $i, $type, $tmp, @coef, $coefSize, $file_index, $s, $e );

   open( HTSVOICE, "> ${voicedir}/${voicename}.htsvoice" );

   # global information
   print HTSVOICE "[GLOBAL]\n";
   print HTSVOICE "HTS_VOICE_VERSION:1.0\n";
   print HTSVOICE "SAMPLING_FREQUENCY:${sr}\n";
   print HTSVOICE "FRAME_PERIOD:${fs}\n";
   print HTSVOICE "NUM_STATES:${nState}\n";
   print HTSVOICE "NUM_STREAMS:" . ( ${ nPdfStreams { 'cmp' } } + 1 ) . "\n";
   print HTSVOICE "STREAM_TYPE:";

   for ( $i = 0 ; $i < @cmp ; $i++ ) {
      if ( $i != 0 ) {
         print HTSVOICE ",";
      }
      $tmp = get_stream_name( $cmp[$i] );
      print HTSVOICE "${tmp}";
   }
   print HTSVOICE ",LPF\n";
   print HTSVOICE "FULLCONTEXT_FORMAT:${fclf}\n";
   print HTSVOICE "FULLCONTEXT_VERSION:${fclv}\n";
   if ($nosilgv) {
      print HTSVOICE "GV_OFF_CONTEXT:";
      for ( $i = 0 ; $i < @slnt ; $i++ ) {
         if ( $i != 0 ) {
            print HTSVOICE ",";
         }
         print HTSVOICE "\"*-${slnt[$i]}+*\"";
      }
   }
   print HTSVOICE "\n";
   print HTSVOICE "COMMENT:\n";

   # stream information
   print HTSVOICE "[STREAM]\n";
   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      print HTSVOICE "VECTOR_LENGTH[${tmp}]:${ordr{$type}}\n";
   }
   $type     = "lpf";
   $tmp      = get_stream_name($type);
   @coef     = split( '\s', `$PERL $datdir/scripts/makefilter.pl $sr 0` );
   $coefSize = @coef;
   print HTSVOICE "VECTOR_LENGTH[${tmp}]:${coefSize}\n";
   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      print HTSVOICE "IS_MSD[${tmp}]:${msdi{$type}}\n";
   }
   $type = "lpf";
   $tmp  = get_stream_name($type);
   print HTSVOICE "IS_MSD[${tmp}]:0\n";
   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      print HTSVOICE "NUM_WINDOWS[${tmp}]:${nwin{$type}}\n";
   }
   $type = "lpf";
   $tmp  = get_stream_name($type);
   print HTSVOICE "NUM_WINDOWS[${tmp}]:1\n";
   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      if ($useGV) {
         print HTSVOICE "USE_GV[${tmp}]:1\n";
      }
      else {
         print HTSVOICE "USE_GV[${tmp}]:0\n";
      }
   }
   $type = "lpf";
   $tmp  = get_stream_name($type);
   print HTSVOICE "USE_GV[${tmp}]:0\n";
   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      if ( $tmp eq "MCP" ) {
         print HTSVOICE "OPTION[${tmp}]:ALPHA=$fw\n";
      }
      elsif ( $tmp eq "LSP" ) {
         print HTSVOICE "OPTION[${tmp}]:ALPHA=$fw,GAMMA=$gm,LN_GAIN=$lg\n";
      }
      else {
         print HTSVOICE "OPTION[${tmp}]:\n";
      }
   }
   $type = "lpf";
   $tmp  = get_stream_name($type);
   print HTSVOICE "OPTION[${tmp}]:\n";

   # position
   $file_index = 0;
   print HTSVOICE "[POSITION]\n";
   $file_size = get_file_size("${voicedir}/dur.pdf");
   $s         = $file_index;
   $e         = $file_index + $file_size - 1;
   print HTSVOICE "DURATION_PDF:${s}-${e}\n";
   $file_index += $file_size;
   $file_size = get_file_size("${voicedir}/tree-dur.inf");
   $s         = $file_index;
   $e         = $file_index + $file_size - 1;
   print HTSVOICE "DURATION_TREE:${s}-${e}\n";
   $file_index += $file_size;

   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      print HTSVOICE "STREAM_WIN[${tmp}]:";
      for ( $i = 0 ; $i < $nwin{$type} ; $i++ ) {
         $file_size = get_file_size("${voicedir}/$win{$type}[$i]");
         $s         = $file_index;
         $e         = $file_index + $file_size - 1;
         if ( $i != 0 ) {
            print HTSVOICE ",";
         }
         print HTSVOICE "${s}-${e}";
         $file_index += $file_size;
      }
      print HTSVOICE "\n";
   }
   $type = "lpf";
   $tmp  = get_stream_name($type);
   print HTSVOICE "STREAM_WIN[${tmp}]:";
   $file_size = get_file_size("$voicedir/$win{$type}[0]");
   $s         = $file_index;
   $e         = $file_index + $file_size - 1;
   print HTSVOICE "${s}-${e}";
   $file_index += $file_size;
   print HTSVOICE "\n";

   foreach $type (@cmp) {
      $tmp       = get_stream_name($type);
      $file_size = get_file_size("${voicedir}/${type}.pdf");
      $s         = $file_index;
      $e         = $file_index + $file_size - 1;
      print HTSVOICE "STREAM_PDF[$tmp]:${s}-${e}\n";
      $file_index += $file_size;
   }
   $type      = "lpf";
   $tmp       = get_stream_name($type);
   $file_size = get_file_size("${voicedir}/${type}.pdf");
   $s         = $file_index;
   $e         = $file_index + $file_size - 1;
   print HTSVOICE "STREAM_PDF[$tmp]:${s}-${e}\n";
   $file_index += $file_size;

   foreach $type (@cmp) {
      $tmp       = get_stream_name($type);
      $file_size = get_file_size("${voicedir}/tree-${type}.inf");
      $s         = $file_index;
      $e         = $file_index + $file_size - 1;
      print HTSVOICE "STREAM_TREE[$tmp]:${s}-${e}\n";
      $file_index += $file_size;
   }
   $type      = "lpf";
   $tmp       = get_stream_name($type);
   $file_size = get_file_size("${voicedir}/tree-${type}.inf");
   $s         = $file_index;
   $e         = $file_index + $file_size - 1;
   print HTSVOICE "STREAM_TREE[$tmp]:${s}-${e}\n";
   $file_index += $file_size;

   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      if ($useGV) {
         $file_size = get_file_size("${voicedir}/gv-${type}.pdf");
         $s         = $file_index;
         $e         = $file_index + $file_size - 1;
         print HTSVOICE "GV_PDF[$tmp]:${s}-${e}\n";
         $file_index += $file_size;
      }
   }
   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      if ( $useGV && $cdgv ) {
         $file_size = get_file_size("${voicedir}/tree-gv-${type}.inf");
         $s         = $file_index;
         $e         = $file_index + $file_size - 1;
         print HTSVOICE "GV_TREE[$tmp]:${s}-${e}\n";
         $file_index += $file_size;
      }
   }

   # data information
   print HTSVOICE "[DATA]\n";
   open( I, "${voicedir}/dur.pdf" ) || die "Cannot open $!";
   @STAT = stat(I);
   read( I, $DATA, $STAT[7] );
   close(I);
   print HTSVOICE $DATA;
   open( I, "${voicedir}/tree-dur.inf" ) || die "Cannot open $!";
   @STAT = stat(I);
   read( I, $DATA, $STAT[7] );
   close(I);
   print HTSVOICE $DATA;

   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      for ( $i = 0 ; $i < $nwin{$type} ; $i++ ) {
         open( I, "${voicedir}/$win{$type}[$i]" ) || die "Cannot open $!";
         @STAT = stat(I);
         read( I, $DATA, $STAT[7] );
         close(I);
         print HTSVOICE $DATA;
      }
   }
   $type = "lpf";
   $tmp  = get_stream_name($type);
   open( I, "${voicedir}/$win{$type}[0]" ) || die "Cannot open $!";
   @STAT = stat(I);
   read( I, $DATA, $STAT[7] );
   close(I);
   print HTSVOICE $DATA;

   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      open( I, "${voicedir}/${type}.pdf" ) || die "Cannot open $!";
      @STAT = stat(I);
      read( I, $DATA, $STAT[7] );
      close(I);
      print HTSVOICE $DATA;
   }
   $type = "lpf";
   $tmp  = get_stream_name($type);
   open( I, "${voicedir}/${type}.pdf" ) || die "Cannot open $!";
   @STAT = stat(I);
   read( I, $DATA, $STAT[7] );
   close(I);
   print HTSVOICE $DATA;

   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      open( I, "${voicedir}/tree-${type}.inf" ) || die "Cannot open $!";
      @STAT = stat(I);
      read( I, $DATA, $STAT[7] );
      close(I);
      print HTSVOICE $DATA;
   }
   $type = "lpf";
   $tmp  = get_stream_name($type);
   open( I, "${voicedir}/tree-${type}.inf" ) || die "Cannot open $!";
   @STAT = stat(I);
   read( I, $DATA, $STAT[7] );
   close(I);
   print HTSVOICE $DATA;

   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      if ($useGV) {
         open( I, "${voicedir}/gv-${type}.pdf" ) || die "Cannot open $!";
         @STAT = stat(I);
         read( I, $DATA, $STAT[7] );
         close(I);
         print HTSVOICE $DATA;
      }
   }
   foreach $type (@cmp) {
      $tmp = get_stream_name($type);
      if ( $useGV && $cdgv ) {
         open( I, "${voicedir}/tree-gv-${type}.inf" ) || die "Cannot open $!";
         @STAT = stat(I);
         read( I, $DATA, $STAT[7] );
         close(I);
         print HTSVOICE $DATA;
      }
   }
   close(HTSVOICE);
}
