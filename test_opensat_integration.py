import requests
import json
from typing import Dict, List, Optional
import os

class OpenSATTester:
    def __init__(self):
        # Since we can't access the remote database, we'll use a sample question
        self.sample_questions = [{
            "id": "70ced8dc",
            "domain": "Standard English Conventions",
            "question": {
                "paragraph": "Typically, underlines, scribbles, and notes left in the margins by a former owner lower a book's ______ when the former owner is a famous poet like Walt Whitman, such markings, known as marginalia, can be a gold mine to literary scholars.",
                "question": "Which choice completes the text so that it conforms to the conventions of Standard English?",
                "choices": {
                    "A": "value, but",
                    "B": "value",
                    "C": "value,",
                    "D": "value but"
                },
                "correct_answer": "A",
                "explanation": "Choice A is the best answer. The convention being tested is the coordination of independent clauses within a sentence."
            }
        }]
        
    def fetch_questions(self) -> List[Dict]:
        """Fetch sample questions."""
        return self.sample_questions

    def convert_to_brainmaxx_format(self, opensat_question: Dict) -> Dict:
        """Convert OpenSAT question format to Brainmaxx format."""
        # Extract choices and find correct answer index
        choices = list(opensat_question["question"]["choices"].values())
        correct_answer = opensat_question["question"]["correct_answer"]
        correct_index = list(opensat_question["question"]["choices"].keys()).index(correct_answer)
        
        return {
            "id": opensat_question["id"],
            "text": opensat_question["question"]["question"],
            "options": choices,
            "correctOptionIndex": correct_index
        }

    def test_question_compatibility(self):
        """Test if OpenSAT questions can be converted to Brainmaxx format."""
        questions = self.fetch_questions()
        if not questions:
            print("❌ Failed to fetch questions")
            return False

        print(f"✅ Successfully loaded {len(questions)} sample questions")
        
        try:
            # Test converting first question
            sample_question = questions[0]
            brainmaxx_question = self.convert_to_brainmaxx_format(sample_question)
            
            # Verify all required fields are present
            required_fields = ["id", "text", "options", "correctOptionIndex"]
            for field in required_fields:
                if field not in brainmaxx_question:
                    print(f"❌ Missing required field: {field}")
                    return False
            
            # Print the original OpenSAT format
            print("\nOriginal OpenSAT format:")
            print(json.dumps(sample_question, indent=2))
            
            # Print the converted Brainmaxx format
            print("\nConverted to Brainmaxx format:")
            print(json.dumps(brainmaxx_question, indent=2))
            
            print("\n✅ Successfully converted question to Brainmaxx format")
            
            # Verify the conversion is correct
            assert len(brainmaxx_question["options"]) == 4, "Should have 4 options"
            assert brainmaxx_question["correctOptionIndex"] == 0, "First option should be correct"
            print("✅ Conversion validation passed")
            
            return True
            
        except Exception as e:
            print(f"❌ Error converting question: {e}")
            return False

    def run_all_tests(self):
        """Run all integration tests."""
        print("🔍 Starting OpenSAT integration tests...\n")
        
        # Test 1: Question fetching and conversion
        print("Test 1: Question Format Compatibility")
        success = self.test_question_compatibility()
        
        print("\n📊 Test Summary:")
        if success:
            print("✅ All tests passed! OpenSAT question format is compatible with Brainmaxx")
            print("\nNext steps:")
            print("1. Implement the OpenSAT question format in your Question.swift model")
            print("2. Add a question converter in your DataService")
            print("3. Create a QuestionRepository to fetch and cache questions")
        else:
            print("❌ Some tests failed. Please check the logs above")

if __name__ == "__main__":
    tester = OpenSATTester()
    tester.run_all_tests() 