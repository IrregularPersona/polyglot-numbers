#let digit-names = ("zero", "uno", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove")
#let teen-names = ("dieci", "undici", "dodici", "tredici", "quattordici", "quindici", "sedici", "diciassette", "diciotto", "diciannove")
#let tens-names = ("", "", "venti", "trenta", "quaranta", "cinquanta", "sessanta", "settanta", "ottanta", "novanta")
#let scale-names = ("", "", "milione", "miliardo", "bilione", "biliardo", "trilione", "triliardo", "quadrilione", "quadriliardo", "quintilione", "quintiliardo")
#let scale-names-plural = ("", "mila", "milioni", "miliardi", "bilioni", "biliardi", "trilioni", "triliardi", "quadrilioni", "quadriliardi", "quintilioni", "quintiliardi")

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
  if ones != 0 and ones != 1 and ones != 8 {
    result = result + digit-names.at(ones) // no dash in italian
  } else if ones == 1 or ones == 8 {
    // Elide the last vowel of the tens name
    result = result.slice(0, count: result.len() - 1) + digit-names.at(ones)
  }
  return result
}

#let convert-group(digits, scale-idx, options) = {
  let hundreds = int(digits.at(0))
  let rest = digits.slice(1)
  
  let parts = ()
  
  // Hundreds place
  if hundreds != 0 and hundreds != 1 {
    parts.push(digit-names.at(hundreds) + "cento")
  } else if hundreds == 1 {
    parts.push("cento")
  }
  
  // Tens and ones
  let rest-text = convert-two-digits(rest)
  if rest-text != "" {
    if digits.at(1) == "8" and hundreds != 0 {
      // Elide the last vowel of "cento" when followed by 80 "ottanta", 81 "ottantuno", ..., 89 "ottantanove" (less common when followed by 8 "otto" alone)
      let last-part = parts.pop()
      last-part = last-part.slice(0, count: last-part.len() - 1)
      parts.push(last-part)
    }
    parts.push(rest-text)
  }
  
  if parts.len() == 0 { return none }
  
  return parts.join("")
}

#let join-parts(parts, options) = {
  let result-parts = ()
  
  for part in parts {
    let text = part.text
    if part.scale > 0 {
      if part.scale == 1 and text == "uno" {
        text = "mille"
      } else if text == "uno" { 
        text = "un " + scale-names.at(part.scale)
      } else {
        text = text + if part.scale > 1 { " " } + scale-names-plural.at(part.scale)
      }
    }
    result-parts.push((text: text, scale: part.scale))
  }

  let small-parts = result-parts.filter(part => part.scale <= 1).map(part => part.text)
  let big-parts = result-parts.filter(part => part.scale > 1).map(part => part.text)

  if small-parts.len() == 0 {
    return big-parts.join(" e ")
  } else if big-parts.len() == 0 {
    return small-parts.join("")
  } else {
    return big-parts.join(" e ") + " e " + small-parts.join("")
  }
}

#let format-negative(text) = {
  "meno " + text
}

#let lang-config = (
  zero-name: "zero",
  convert-group: convert-group,
  join-parts: join-parts,
  format-negative: format-negative,
)
