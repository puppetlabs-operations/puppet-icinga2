class icinga2(
  $use_debmon_repo = false,
){

  if $use_debmon_repo {
    include icinga2::repos
  }
}
