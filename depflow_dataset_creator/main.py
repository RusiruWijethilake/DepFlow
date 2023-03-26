from sinhala_transliterate import transliterate

# English text to be converted
english_text = "apita sinhala unicode wage"

# Convert English text to Sinhala Unicode text
sinhala_text = transliterate(english_text, source='en', target='si')

# Print Sinhala Unicode text
print(sinhala_text)
