createValueBox <- function(value, value.check, max.value,
                           good, average, title,
                           c.ok = "green", i.ok = "thumbs-up",
                           c.warning = "yellow", i.warning = "flash",
                           c.danger = "red", i.danger = "fire",
                           lib = "glyphicon")
  {
  # Set valuebox parameter depending on performance
  if(value.check >= as.numeric(good) | value.check == 0){
    c.vb <- c.ok
    i.vb <- i.ok
  } else if(value.check >= as.numeric(average)){
    c.vb <- c.warning
    i.vb <- i.warning
  } else {
    c.vb <- c.danger
    i.vb <- i.danger
  }
  
  valueBox(
    value, title,
    icon = icon(i.vb, lib = lib),
    color = c.vb
  )
}
