import json
import os
from PIL import Image  # For verifying images

def display_question(question_data):
    """Display a question in a readable format."""
    print("\n" + "="*80)
    print(f"Question ID: {question_data['id']}")
    print(f"Subject: {question_data['subject']}")
    print(f"Topic: {question_data['topic']}")
    print(f"Skill: {question_data['skill']}")
    print(f"Difficulty: {question_data['difficulty']}")
    print("-"*80)
    
    # Question text
    print("\nQuestion:")
    print(question_data['question']['text'])
    
    # Options
    if question_data['question']['options']:
        print("\nOptions:")
        for option in question_data['question']['options']:
            print(f"- {option}")
    
    # Correct answers
    print("\nCorrect Answer(s):")
    for answer in question_data['question']['correct_answers']:
        print(f"- {answer}")
    
    # Images
    if question_data['images']:
        print("\nImages:")
        for image_path in question_data['images']:
            full_path = os.path.join("data/questions/images", image_path)
            if os.path.exists(full_path):
                img = Image.open(full_path)
                print(f"- {image_path} ({img.size[0]}x{img.size[1]} pixels)")
            else:
                print(f"- {image_path} (not found)")
    
    # Explanation
    print("\nExplanation:")
    print(question_data['explanation']['text'])
    
    print("\n" + "="*80)

def test_math_display():
    """Test loading and displaying math questions."""
    try:
        # Load the processed math questions
        with open("data/processed_questions/math_questions.json", "r") as f:
            math_data = json.load(f)
        
        # Get the first topic's first question
        first_topic = next(iter(math_data['topics'].values()))
        if first_topic:
            first_question = first_topic[0]
            
            # Display the question
            display_question(first_question)
            
            # Print original MathML for verification
            print("\nOriginal MathML for question:")
            print(first_question['question']['original_math'])
            
            return True
    except Exception as e:
        print(f"Error testing math display: {str(e)}")
        return False

def main():
    print("Testing question display...")
    if test_math_display():
        print("\n✅ Successfully loaded and displayed question")
        print("\nNext steps:")
        print("1. Verify the math formatting is correct")
        print("2. Check if images are loading properly")
        print("3. Confirm all question components are present")
    else:
        print("\n❌ Error loading or displaying question")

if __name__ == "__main__":
    main() 