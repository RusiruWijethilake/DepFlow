import csv
from googletrans import Translator

# Initialize translator
translator = Translator()

print(translator.detect("Hello"))
print(translator.translate("Hello", dest='si'))

# Define input and output file names
input_file_name = 'original_dataset.csv'
output_file_name = 'output.csv'

# Open input and output files
with open(input_file_name, 'r', newline='') as input_file, open(output_file_name, 'w', newline='') as output_file:
    reader = csv.DictReader(input_file)
    fieldnames = ['post_text', 'label']
    writer = csv.DictWriter(output_file, fieldnames=fieldnames)

    # Write the header row to the output file
    writer.writeheader()

    # Process each row in the input file
    for row in reader:
        text = row['post_text']  # Get the English text from the "post_text" column
        label = row['label']  # Get the label from the "label" column

        # Translate the English text to mixed Sinhala and English
        translation = translator.translate(text, dest='si', src='en')
        mixed_text = translation.text

        # Write the mixed text and label to the output file
        writer.writerow({'post_text': mixed_text, 'label': label})
