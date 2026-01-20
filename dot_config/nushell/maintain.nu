let maintain_state = ($env.XDG_STATE_HOME | path join "nu" "last_maintenance")
let weekly_update_state = ($env.XDG_STATE_HOME | path join "nu" "last_weekly_update")
if not ($maintain_state | path exists) {
  try { mkdir ($maintain_state | path dirname) } catch { }
}
if not ($weekly_update_state | path exists) {
  try { mkdir ($weekly_update_state | path dirname) } catch { }
}
let need_run = if ($maintain_state | path exists) {
  let age = (date now | date to-timezone utc) - ((ls $maintain_state | get 0.modified) | date to-timezone utc)
  $age > 1day
} else {
  true
}
if $need_run {
  "" | save -f $maintain_state
  if (which trash-empty | is-not-empty) {
    job spawn { ^trash-empty 30 }
  }
}
let need_weekly_update = if ($weekly_update_state | path exists) {
  let age = (date now | date to-timezone utc) - ((ls $weekly_update_state | get 0.modified) | date to-timezone utc)
  $age > 7day
} else {
  true
}
if $need_weekly_update {
  "" | save -f $weekly_update_state
  if (which update-all | is-not-empty) {
    job spawn { ^update-all }
  }
}
