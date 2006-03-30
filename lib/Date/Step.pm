package Date::Step;
use strict;
use base 'Date';
use Carp;
use vars '$VERSION';

$VERSION  = 0.2;

sub new {
  # shift self "object" reference to variable $class
  my $class = shift;
  # create object - NOTE: Nothing is set here!
  my $self = {
     # decribes start date
     _start_year  => 1900,
     _start_month => 01,
     _start_day   => 01,
     _start_hour  => 00,
     # describes end date
     _end_year  => 1900,
     _end_month => 01,
     _end_day   => 01,
     _end_hour  => 00,
     # describes current date
     _curr_year  => 1900,
     _curr_month => 01,
     _curr_day   => 01,
     _curr_hour  => 00,
     # describes increment atomically
     _incr_year  => 0,
     _incr_month => 0,
     _incr_day   => 0,
     _incr_hour  => 0,
     # output string format - syntax compatible with unix `date` utility
     # default is YYYYMMDDHH
     _date_format => '%Y%m%d%h', 
  };
  # "bless" reference to anonymous hash, $self, to $class object reference; return
  return bless $self, $class;
}

# COMMANDS (set_)

sub set_start {
  # shift self "object" reference to variable $self
  my $self = shift;
  my $str = shift;
  chomp($str);
  $str =~ s/ //g;
  if ($str =~ m/([\d][\d][\d][\d])([\d][\d])([\d][\d])([\d][\d])/) {
    $self->{_start_year}  = $1;
    $self->{_start_month} = $2;
    $self->{_start_day}   = $3;
    $self->{_start_hour}  = $4;
  }
  # set _curr_* to _start_*  
  $self->reset();
}

sub set_end {
  # shift self "object" reference to variable $self
  my $self = shift;
  my $str = shift;
  chomp($str);
  $str =~ s/ //g;
  if ($str =~ m/([\d][\d][\d][\d])([\d][\d])([\d][\d])([\d][\d])/) {
    $self->{_end_year}  = $1;
    $self->{_end_month} = $2;
    $self->{_end_day}   = $3;
    $self->{_end_hour}  = $4;
  } elsif($str =~ m/([\d]*[yY])?([\d]*[mM])?([\d]*[dD])?([\d]*[hH])?/) {                  
     ## check for relative date notation & compute start date; implies subtraction of specified time      
     my $tmp = {
      # describes current date
      _curr_year  => $self->{_start_year},
      _curr_month => $self->{_start_month},
      _curr_day   => $self->{_start_day},
      _curr_hour  => $self->{_start_hour},
      # describes increment atomically
      _incr_year  => 0,
      _incr_month => 0,
      _incr_day   => 0,
      _incr_hour  => 0,        
    };
    if ($1) {
      $tmp->{_incr_year} = $1;
      $tmp->{_incr_year} =~ s/[yY]//g;    
    }
    if ($2) {
      $tmp->{_incr_month} = $2;
      $tmp->{_incr_month} =~ s/[mM]//g;    
    }
    if ($3) {
      $tmp->{_incr_day} = $3;
      $tmp->{_incr_day} =~ s/[dD]//g;    
    }
    if ($4) {
      $tmp->{_incr_hour} = $4;
      $tmp->{_incr_hour} =~ s/[hH]//g;    
    }
    add_hours($tmp)  if $tmp->{_incr_hour} > 0;
    add_days($tmp)   if $tmp->{_incr_day} > 0;
    add_months($tmp) if $tmp->{_incr_month} > 0;
    add_years($tmp)  if $tmp->{_incr_year} > 0;
    $self->{_end_year} = get_padded($tmp->{_curr_year});
    $self->{_end_month} = get_padded($tmp->{_curr_month});
    $self->{_end_day} = get_padded($tmp->{_curr_day});
    $self->{_end_hour} = get_padded($tmp->{_curr_hour});
  }
}

sub set_increment {
  # shift self "object" reference to variable $self
  my $self = shift;
  my $increment = shift;
  # break up using regex on format ([\d]*[yY])?([\d]*[mM])?([\d]*[dD])?([\d]*[hH])?
  chomp($increment);
  $increment =~ s/ //g; # remove spaces
  if($increment =~ m/([\d]*[yY])?([\d]*[mM])?([\d]*[dD])?([\d]*[hH])?/) {
    if ($1) {
      $self->{_incr_year} = $1;
      $self->{_incr_year} =~ s/[yY]//g;    
    }
    if ($2) {
      $self->{_incr_month} = $2;
      $self->{_incr_month} =~ s/[mM]//g;    
    }
    if ($3) {
      $self->{_incr_day} = $3;
      $self->{_incr_day} =~ s/[dD]//g;    
    }
    if ($4) {
      $self->{_incr_hour} = $4;
      $self->{_incr_hour} =~ s/[hH]//g;    
    }
  }
}

sub set_format {
  # shift self "object" reference to variable $self
  my $self = shift;
  my $format = shift;
  chomp($format);
  $self->{_date_format} = $format;
}

sub reset {
  # shift self "object" reference to variable $self
  my $self = shift;
  # set _curr_* to _start_*
  $self->{_curr_year}  = $self->{_start_year};
  $self->{_curr_month} = $self->{_start_month};
  $self->{_curr_day}   = $self->{_start_day};
  $self->{_curr_hour}  = $self->{_start_hour};    
}

# QUERIES (get_)

sub get_start {
  # shift self "object" reference to variable $self
  my $self = shift;
}

sub get_end {
  # shift self "object" reference to variable $self
  my $self = shift;
}

sub get_increment {
  # shift self "object" reference to variable $self
  my $self = shift;
}

sub get_current {
  # shift self "object" reference to variable $self
  my $self = shift;
  my $str = $self->get_formatted_date($self);
  return $str;
}

sub get_formatted_date {
  my $self = shift;
  my $format = $self->{_date_format};
  my $legend = {
    B => get_full_month($self->{_curr_month}),  # January...December
    b => get_short_month($self->{_curr_month}), # Jan...Dec
    d => get_padded($self->{_curr_day}),        # Padded day of month; 01-{28,29,30,31}
    e => $self->{_curr_day},                    # zero padded day of month 1-{28,29,30,31}
    h => get_short_month($self->{_curr_month}), # Jan...Dec
    k => get_padded($self->{_curr_hour}),       # padded hour of day; 00-23
    l => $self->{_curr_hour},                   # zero padded hour of dayl 0-23
    m => get_padded($self->{_curr_month}),      # padded month; 01-12
    Y => $self->{_curr_year},                   # four digit year
    y => get_decade($self->{_curr_year}),       # two digit year; 00-99
  };
  # replace formatting with actual values!
  $format =~ s/%([bBdehklmYy]+?)/exists($legend->{$1}) ? $legend->{$1} : "%$1%"/ge;
  return $format;
}

sub get_full_month {
  my $month = shift;
  my $name = '';
  if ($month == 1) {
    $name = 'January';
  } elsif ($month == 2) {
    $name = 'February';
  } elsif ($month == 3) {
    $name = 'March';
  } elsif ($month == 4) {
    $name = 'April';
  } elsif ($month == 5) {
    $name = 'May';
  } elsif ($month == 6) {
    $name = 'June';
  } elsif ($month == 7) {
    $name = 'July';
  } elsif ($month == 8) {
    $name = 'August';
  } elsif ($month == 9) {
    $name = 'September';
  } elsif ($month == 10) {
    $name = 'October';
  } elsif ($month == 11) {
    $name = 'November';
  } elsif ($month == 12) {
    $name = 'December';
  } else {
    $name = 'xXxXx';
  }
  return $name;
}

sub get_short_month {
  my $month = shift;
  my $name = '';
  if ($month == 1) {
    $name = 'Jan';
  } elsif ($month == 2) {
    $name = 'Feb';
  } elsif ($month == 3) {
    $name = 'Mar';
  } elsif ($month == 4) {
    $name = 'Apr';
  } elsif ($month == 5) {
    $name = 'May';
  } elsif ($month == 6) {
    $name = 'Jun';
  } elsif ($month == 7) {
    $name = 'Jul';
  } elsif ($month == 8) {
    $name = 'Aug';
  } elsif ($month == 9) {
    $name = 'Sep';
  } elsif ($month == 10) {
    $name = 'Oct';
  } elsif ($month == 11) {
    $name = 'Nov';
  } elsif ($month == 12) {
    $name = 'Dec';
  } else {
    $name = 'xXxXx';
  }
  return $name;
}

sub get_padded {
  my $retstr = shift;
  chomp($retstr);
  $retstr =~ s/ //g; # get rid of spaces
  if ($retstr =~ m/^0*$/) {
    $retstr = '00';
  } else {
    $retstr =~ s/^0*//g; # strip existing pads  
    if ($retstr < 10) {
      $retstr =  '0'.$retstr;
    }
  }
  return $retstr;
}

sub get_decade {
  my $year = shift;
  $year =~ m/[\d][\d]([\d][\d])/;
  return $1;
}

sub get_next {
  # shift self "object" reference to variable $self
  my $self = shift;
  $self->next();
  return $self->get_current();
}

sub next {
  # shift self "object" reference to variable $self
  my $self = shift;
  my $ok = 1;
  if ($self->pastEnd($self)) {
    $ok = 0;
  } else {
    add_hours($self)  if $self->{_incr_hour} > 0;
    add_days($self)   if $self->{_incr_day} > 0;
    add_months($self) if $self->{_incr_month} > 0;
    add_years($self)  if $self->{_incr_year} > 0;  
  }
  # check if this is past the specified end date
  return $ok;
}

# Date funcs

sub pastEnd {
  my $self = shift;
  my $year = $self->{_curr_year};
  my $month = get_padded($self->{_curr_month});
  my $day = get_padded($self->{_curr_day});
  my $hour = get_padded($self->{_curr_hour});
  my $datestr = "$year$month$day$hour";
  my $end = 0;
  my $endstr = "$self->{_end_year}$self->{_end_month}$self->{_end_day}$self->{_end_hour}";
  if ($datestr >= $endstr) {
    $end = 1;
  }
  return $end;
}

sub isLeap {
  my $year = shift;
  # assumes 4 digit year
  $year =~ m/[\d][\d]([\d][\d])/;
  my $decade = $1;
  my $century = $year - $decade;
  my $isLeap = 0;
  if ($decade == '00' && $century % 400 == 0) {
    $isLeap = 1;  
  } elsif (($decade % 4 == 0)) {
    $isLeap = 1;
  }
  return $isLeap;
}

sub add_hours {
  # shift self "object" reference to variable $self
  my $self = shift;
  $self->{_curr_hour} += $self->{_incr_hour};
  my $days = 0;
  while ($self->{_curr_hour} >= 24) {
    $self->{_curr_hour} -= 24;
    $days++;
  }
  $self->{_curr_day} += $days;
  my $done = 0;
  while (!$done) {  
    if (($self->{_curr_day} >= 29) && (!isLeap($self->{_curr_year})) && (
      $self->{_curr_month} == 2      # february leap year
    )) {
      # adjust month, reset day
        $self->{_curr_day} -= 28;
        $self->{_curr_month}++;      
    } elsif (($self->{_curr_day} >= 30) && (
      $self->{_curr_month} == 2      # february non leap year
    )) {
      # adjust month, reset day
        $self->{_curr_day} -= 29;
        $self->{_curr_month}++;      
    } elsif (($self->{_curr_day} >= 31) && (
      $self->{_curr_month} == 4  ||  # april
      $self->{_curr_month} == 6  ||  # june
      $self->{_curr_month} == 9  ||  # september
      $self->{_curr_month} == 11     # november
    )) {
      # adjust month, reset day
        $self->{_curr_day} -= 30;
        $self->{_curr_month}++;      
    } elsif (($self->{_curr_day} >= 32) && (
      $self->{_curr_month} == 1  ||  # january
      $self->{_curr_month} == 3  ||  # march
      $self->{_curr_month} == 5  ||  # may
      $self->{_curr_month} == 7  ||  # july  
      $self->{_curr_month} == 8  ||  # august
      $self->{_curr_month} == 10     # october  
    )) {
      # adjust month, reset day
        $self->{_curr_day} -= 31;
        $self->{_curr_month}++;      
    } elsif (($self->{_curr_day} > 31) && ( $self->{_curr_month} == 12)) {
      # increment year, reset month, reset day
        $self->{_curr_day} -= 31;
        $self->{_curr_month} = 1;
        $self->{_curr_year}++;        
    } else {
      $done++;
    }
  }
}

sub add_days {
  # shift self "object" reference to variable $self
  my $self = shift;
  $self->{_curr_day} += $self->{_incr_day};
  my $done = 0;
  while (!$done) {  
    if (($self->{_curr_day} >= 29) && (!isLeap($self->{_curr_year})) && (
      $self->{_curr_month} == 2      # february leap year
    )) {
      # adjust month, reset day
        $self->{_curr_day} -= 28;
        $self->{_curr_month}++;      
    } elsif (($self->{_curr_day} >= 30) && (
      $self->{_curr_month} == 2      # february non leap year
    )) {
      # adjust month, reset day
        $self->{_curr_day} -= 29;
        $self->{_curr_month}++;      
    } elsif (($self->{_curr_day} >= 31) && (
      $self->{_curr_month} == 4  ||  # april
      $self->{_curr_month} == 6  ||  # june
      $self->{_curr_month} == 9  ||  # september
      $self->{_curr_month} == 11     # november
    )) {
      # adjust month, reset day
        $self->{_curr_day} -= 30;
        $self->{_curr_month}++;      
    } elsif (($self->{_curr_day} >= 32) && (
      $self->{_curr_month} == 1  ||  # january
      $self->{_curr_month} == 3  ||  # march
      $self->{_curr_month} == 5  ||  # may
      $self->{_curr_month} == 7  ||  # july  
      $self->{_curr_month} == 8  ||  # august
      $self->{_curr_month} == 10     # october  
    )) {
      # adjust month, reset day
        $self->{_curr_day} -= 31;
        $self->{_curr_month}++;      
    } elsif (($self->{_curr_day} > 31) && ( $self->{_curr_month} == 12)) {
      # increment year, reset month, reset day
        $self->{_curr_day} -= 31;
        $self->{_curr_month} = 1;
        $self->{_curr_year}++;        
    } else {
      $done++;
    }
  }

}

sub add_months {
  # shift self "object" reference to variable $self
  my $self = shift;
  $self->{_curr_month} += $self->{_incr_month};
  while ($self->{_curr_month} > 12) {
    $self->{_curr_month} -= 12;
    $self->{_curr_year}++;
  }
  # check for leap year and feb 29 - could happen!
  if (($self->{_curr_day} >= 29) && (!isLeap($self->{_curr_year})) && (
    $self->{_curr_month} == 2      # february leap year
  )) {
    # adjust month, reset day
      $self->{_curr_day} -= 28;
      $self->{_curr_month}++;        
  } elsif (($self->{_curr_day} >= 30) && (
    $self->{_curr_month} == 2      # february non leap year
  )) {
    # adjust month, reset day
      $self->{_curr_day} -= 29;
      $self->{_curr_month}++;        
  }  
}

sub add_years {
  # shift self "object" reference to variable $self
  my $self = shift;
  $self->{_curr_year} += $self->{_incr_year};
  if (($self->{_curr_day} >= 29) && (!isLeap($self->{_curr_year})) && (
    $self->{_curr_month} == 2      # february leap year
  )) {
    # adjust month, reset day
      $self->{_curr_day} -= 28;
      $self->{_curr_month}++;        
  } elsif (($self->{_curr_day} >= 30) && (
    $self->{_curr_month} == 2      # february non leap year
  )) {
    # adjust month, reset day
      $self->{_curr_day} -= 29;
      $self->{_curr_month}++;        
  }
} 

1;

__END__

=head1 NAME

Date::Step - A basic date iterator

=head1 SYNOPSIS

    use Date::Step

    my $step = Date::Step->new();  # new object
    $step->set_start('20051008');  # start date
    $step->set_end('20061008');    # end date
    $step->set_increment('1d12h'); # date increment length
    $step->set_format('%Y %B %e'); # format of returned date string

    my $date;
    do {
      $date = $step->get_current();
      print "$date\n";
    } while ($step->next());

=head1 DESCRIPTION

C<Date::Step> is a basic date iterator class.

Returned dates are done so using the convention set up by the Unix 'date' program:

    B = January...December
    b = Jan...Dec
    d = Padded day of month; 01-{28,29,30,31}
    e = zero padded day of month 1-{28,29,30,31}
    h = Jan...Dec
    k = padded hour of day; 00-23
    l = zero padded hour of dayl 0-23
    m = padded month; 01-12
    Y = four digit year
    y = two digit year; 00-99

The default start date is Jan 1 1900, but there is no reason why the date can't be set earlier than that.  If there is a max date, it is probably after the year 9999. 
=head1 AUTHOR

Brett D. Estrade - <estrabd AT mailcan DOT com>

=head1 TODO

Write some tests and more useful documentation.

=head1 CAVEATS

This module handles hours as the smallest division of time.  If you wish to have a more fine grained capability, please let me know.

I am not sure how robust this module is to doing things like changing the format or the increment amount arbitrarily through out the iterative generation of daytes, but I do not see why it would cause problems.  The only issue that might possibly come up would be losing some time during the transition phase.  Again, I don't know bc I have not tested it.

There is no "previous" date, but it would probably be a neat features.

=head1 BUGS

Please send reports to me.

=head1 AVAILABILITY

=head1 ACKNOWLEDGEMENTS

Bug reports who supply patches for a cool new feature or a bug fix get there name here :)

=head1 COPYRIGHT

This code is released under the same terms as Perl.
