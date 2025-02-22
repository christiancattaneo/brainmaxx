import os
import json
from dotenv import load_dotenv
from openai import OpenAI
from pathlib import Path

# Load the .env file from the current directory
load_dotenv()

# Initialize OpenAI client
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise ValueError("❌ No API key found in .env file")

client = OpenAI(api_key=api_key)

def generate_question():
    """Generate a sample SAT question"""
    system_prompt = """You are an AI that generates SAT practice questions.
IMPORTANT: You must ONLY return a valid JSON object with no additional text, markdown formatting, or code blocks."""

    user_prompt = """Generate one SAT-style multiple choice question for Mathematics (medium difficulty) using this exact JSON structure:
{
    "subject": "Mathematics",
    "difficulty": "medium",
    "question": "The actual question text goes here",
    "options": ["A) First option", "B) Second option", "C) Third option", "D) Fourth option"],
    "correct_answer": "A",
    "explanations": {
        "A": "Explanation why A is correct",
        "B": "Explanation why B is wrong and why A is better",
        "C": "Explanation why C is wrong and why A is better",
        "D": "Explanation why D is wrong and why A is better"
    }
}

Remember: Return ONLY the JSON object, no other text or formatting."""

    try:
        response = client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            temperature=0.7
        )
        
        # Get the response content and parse it as JSON
        content = response.choices[0].message.content.strip()
        print("\nRaw API Response:", content)  # Debug print
        return json.loads(content)
    except Exception as e:
        print("❌ Error generating question:", str(e))
        return None

def get_wrong_answer_explanation(question_data, selected_option):
    """Get explanation for why the selected answer is wrong"""
    if selected_option == question_data["correct_answer"]:
        return "✅ Correct! " + question_data["explanations"][selected_option]
    else:
        return f"❌ Incorrect. {question_data['explanations'][selected_option]}\n\nThe correct answer is {question_data['correct_answer']}: {question_data['explanations'][question_data['correct_answer']]}"

# Test the functionality
try:
    print("🔑 API key loaded successfully!")
    
    # Generate a question
    question_data = generate_question()
    if question_data:
        # Display the question
        print("\n📝 Question:")
        print(question_data["question"])
        print("\nOptions:")
        for option in question_data["options"]:
            print(option)
            
        # Simulate wrong answer (let's try option B)
        print("\n🤔 Testing with wrong answer 'B':")
        explanation = get_wrong_answer_explanation(question_data, "B")
        print("\n" + explanation)
        
        # Simulate correct answer
        print("\n🎯 Testing with correct answer '" + question_data["correct_answer"] + "':")
        explanation = get_wrong_answer_explanation(question_data, question_data["correct_answer"])
        print("\n" + explanation)
        
except Exception as e:
    print("❌ Error:", str(e)) 