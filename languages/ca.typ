#let digit-names = (
  "zero", "un", "dos", "tres", "quatre",
  "cinc", "sis", "set", "vuit", "nou"
)

#let teen-names = (
  "deu", "onze", "dotze", "tretze", "catorze",
  "quinze", "setze", "disset", "divuit", "dinou"
)

#let tens-names = (
  "", "", "vint", "trenta", "quaranta",
  "cinquanta", "seixanta", "setanta",
  "vuitanta", "noranta"
)

#let scale-names = (
  "",
  "mil",
  "milió",
  "mil milions",
  "bilió",
  "mil bilions",
  "trilió",
  "mil trilions"
  "quadrilió",
  "mil quadrilions",
  "quintilió",
  "mil quintilions",
  "sextilió",
  "mil sextilions",
  "septilió",
  "mil septilions",
  "octilió",
  "mil octilions",
  "nonilió",
  "mil nonilions",
  "decilió"
)

#let convert-two-digits(digits) = {
  let tens = int(digits.at(0))
  let ones = int(digits.at(1))

  if tens == 0 {
    return if ones == 0 { "" } else { digit-names.at(ones) }
  }

  if tens == 1 {
    return teen-names.at(ones)
  }

  let result = tens-names.at(tens)

  if ones != 0 {
    // En català diem "vint-i-un", "trenta-dos", etc.
    let connector = if tens == 2 { "-i-" } else { "-" }
    result = result + connector + digit-names.at(ones)
  }

  return result
}

#let convert-group(digits, scale-idx, options) = {
  let hundreds = int(digits.at(0))
  let rest = digits.slice(1)

  let parts = ()

  if hundreds != 0 {
    if hundreds == 1 {
      parts.push("cent")
    } else {
      parts.push(digit-names.at(hundreds) + "-cents")
    }
  }

  let rest-text = convert-two-digits(rest)
  if rest-text != "" {
    parts.push(rest-text)
  }

  if parts.len() == 0 { return none }

  // En català no fem servir "i"
  return parts.join(" ")
}

#let join-parts(parts, options) = {
  let result-parts = ()

  for part in parts {
    let text = part.text

    if part.scale > 0 {
      let scale-name = scale-names.at(part.scale)

      if text == "un" and scale-name.starts-with("mil") {  
        text = scale-name // En català diem "mil" no pas "un mil"
      } else {
        if part.scale >= 2 and text != "un" {
          scale-name = scale-name + "s"
        }
        text = text + " " + scale-name
      }
    }

    result-parts.push(text)
  }

  return result-parts.join(" ")
}

#let format-negative(text) = {
  "menys " + text
}

#let lang-config = (
  zero-name: "zero",
  convert-group: convert-group,
  join-parts: join-parts,
  format-negative: format-negative,
)
