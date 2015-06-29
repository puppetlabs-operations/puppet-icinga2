class icinga2(
  $use_debmon_repo = false,
){

  if $use_debmon_repo != false {
    include icinga2::repos
  }
}
