import Foundation

struct SampleData {
    // MARK: - Math Questions by Topic
    
    // Algebra Topic
    private static let algebraQuestions: [Question] = [
        // Easy Algebra Questions
        Question(
            id: "math-002",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Linear equations in one variable",
            difficulty: .easy,
            lesson: nil,
            question: Question.Content(
                text: "Solve for x:",
                originalMath: "2x + 5 = 15",
                mathOptions: [
                    "4",
                    "5",
                    "7",
                    "10"
                ],
                correctAnswers: ["5"]
            ),
            explanation: Question.Explanation(
                text: "Subtract 5 from both sides, then divide by 2:",
                originalMath: """
                2x + 5 = 15
                2x = 15 - 5
                2x = 10
                x = 10/2
                x = 5
                """
            ),
            images: []
        ),
        
        Question(
            id: "math-003",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Exponents and squares",
            difficulty: .easy,
            lesson: nil,
            question: Question.Content(
                text: "What is the value of 6² - 4²?",
                originalMath: "What is the value of 6^2 - 4^2?",
                mathOptions: [
                    "12",
                    "20",
                    "36",
                    "20"
                ],
                correctAnswers: ["20"]
            ),
            explanation: Question.Explanation(
                text: "Using the difference of squares formula: 6² - 4² = (6+4)(6-4) = 2 × 10 = 20",
                originalMath: """
                6^2 - 4^2 = (6+4)(6-4)
                = 10 × 2
                = 20
                """
            ),
            images: []
        ),
        
        Question(
            id: "math-004",
            type: "multiple-choice",
            subject: "Math",
            topic: "Geometry",
            skill: "Area of rectangles",
            difficulty: .easy,
            lesson: nil,
            question: Question.Content(
                text: "If a rectangle has a length of 10 and a width of 4, what is its area?",
                originalMath: "Area = length × width",
                mathOptions: [
                    "14",
                    "20",
                    "40",
                    "44"
                ],
                correctAnswers: ["40"]
            ),
            explanation: Question.Explanation(
                text: "The area is given by: Area = length × width = 10 × 4 = 40",
                originalMath: """
                Area = length × width
                = 10 × 4
                = 40
                """
            ),
            images: []
        ),
        
        Question(
            id: "math-005",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Evaluating expressions",
            difficulty: .easy,
            lesson: nil,
            question: Question.Content(
                text: "If x = 3, what is the value of x³ - x?",
                originalMath: "If x = 3, find x^3 - x",
                mathOptions: [
                    "24",
                    "18",
                    "20",
                    "15"
                ],
                correctAnswers: ["24"]
            ),
            explanation: Question.Explanation(
                text: "Substitute x = 3: 3³ - 3 = 27 - 3 = 18",
                originalMath: """
                x = 3
                3^3 - 3
                = 27 - 3
                = 18
                """
            ),
            images: []
        ),
        
        // Additional Easy Algebra Questions
        Question(
            id: "math-006",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Linear equations",
            difficulty: .easy,
            lesson: nil,
            question: Question.Content(
                text: "If x + 2 = 10, what is x?",
                originalMath: "x + 2 = 10",
                mathOptions: [
                    "5",
                    "6",
                    "7",
                    "8"
                ],
                correctAnswers: ["8"]
            ),
            explanation: Question.Explanation(
                text: "Subtract 2 from both sides: x = 10 - 2 = 8",
                originalMath: """
                x + 2 = 10
                x = 10 - 2
                x = 8
                """
            ),
            images: []
        ),
        
        // Medium Algebra Questions
        Question(
            id: "math-011",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Linear equations",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "If 3x - 5 = 16, what is x?",
                originalMath: "3x - 5 = 16",
                mathOptions: [
                    "5",
                    "6",
                    "7",
                    "8"
                ],
                correctAnswers: ["7"]
            ),
            explanation: Question.Explanation(
                text: "Add 5 to both sides: 3x = 21, then divide by 3: x = 7",
                originalMath: """
                3x - 5 = 16
                3x = 16 + 5
                3x = 21
                x = 21/3
                x = 7
                """
            ),
            images: []
        ),
        
        Question(
            id: "math-012",
            type: "multiple-choice",
            subject: "Math",
            topic: "Geometry",
            skill: "Triangle area",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "The area of a triangle is 24, and its base is 6. What is its height?",
                originalMath: "<math>\\text{Given: Area} = 24, \\text{ base} = 6 \\\\ \\frac{1}{2} \\times \\text{base} \\times \\text{height} = 24</math>",
                mathOptions: [
                    "<math>4</math>",
                    "<math>6</math>",
                    "<math>8</math>",
                    "<math>10</math>"
                ],
                correctAnswers: ["<math>8</math>"]
            ),
            explanation: Question.Explanation(
                text: "Use the area formula: (1/2) × base × height = 24. Solving for height: (1/2) × 6 × h = 24, so 3h = 24, therefore h = 8",
                originalMath: "<math>\\begin{align*} \\frac{1}{2} \\times 6 \\times h &= 24 \\\\ 3h &= 24 \\\\ h &= \\frac{24}{3} \\\\ h &= 8 \\end{align*}</math>"
            ),
            images: []
        ),
        
        Question(
            id: "math-013m",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Polynomial evaluation",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "What is the value of (2x + 3)(x - 4) when x = 5?",
                originalMath: "<math>(2x + 3)(x - 4) \\text{ when } x = 5</math>",
                mathOptions: [
                    "<math>3</math>",
                    "<math>7</math>",
                    "<math>9</math>",
                    "<math>13</math>"
                ],
                correctAnswers: ["<math>13</math>"]
            ),
            explanation: Question.Explanation(
                text: "Substitute x = 5: (2(5) + 3)(5 - 4) = (10 + 3)(1) = 13",
                originalMath: "<math>\\begin{align*} (2(5) + 3)(5 - 4) &= (10 + 3)(1) \\\\ &= 13 \\times 1 \\\\ &= 13 \\end{align*}</math>"
            ),
            images: []
        ),
        
        Question(
            id: "math-014m",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Quadratic equations",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "Solve for x:",
                originalMath: "<math>x^2 - 9 = 0</math>",
                mathOptions: [
                    "<math>3</math>",
                    "<math>-3</math>",
                    "<math>\\pm3</math>",
                    "<math>9</math>"
                ],
                correctAnswers: ["<math>\\pm3</math>"]
            ),
            explanation: Question.Explanation(
                text: "Factor the equation into (x - 3)(x + 3) = 0. Then solve for x.",
                originalMath: "<math>\\begin{align*} x^2 - 9 &= 0 \\\\ (x - 3)(x + 3) &= 0 \\\\ x &= \\pm3 \\end{align*}</math>"
            ),
            images: []
        ),
        
        Question(
            id: "math-015m",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Quadratic equations",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "What is the sum of the solutions to x² - 5x + 6 = 0?",
                originalMath: "<math>x^2 - 5x + 6 = 0</math>",
                mathOptions: [
                    "<math>2</math>",
                    "<math>3</math>",
                    "<math>5</math>",
                    "<math>6</math>"
                ],
                correctAnswers: ["<math>5</math>"]
            ),
            explanation: Question.Explanation(
                text: "Factor: (x - 2)(x - 3) = 0. Solutions: x = 2, x = 3. Sum: 2 + 3 = 5",
                originalMath: "<math>\\begin{align*} x^2 - 5x + 6 &= 0 \\\\ (x - 2)(x - 3) &= 0 \\\\ x &= 2 \\text{ or } x = 3 \\\\ \\text{Sum} &= 2 + 3 = 5 \\end{align*}</math>"
            ),
            images: []
        ),
        
        Question(
            id: "math-016m",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Systems of equations",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "If 4x + 2y = 10 and 2x - y = 3, what is x?",
                originalMath: "<math>\\begin{align*} 4x + 2y &= 10 \\\\ 2x - y &= 3 \\end{align*}</math>",
                mathOptions: [
                    "<math>1</math>",
                    "<math>2</math>",
                    "<math>3</math>",
                    "<math>4</math>"
                ],
                correctAnswers: ["<math>2</math>"]
            ),
            explanation: Question.Explanation(
                text: "From second equation: y = 2x - 3. Substitute into first equation: 4x + 2(2x - 3) = 10. Solve: 4x + 4x - 6 = 10, 8x = 16, x = 2",
                originalMath: "<math>\\begin{align*} y &= 2x - 3 \\\\ 4x + 2(2x - 3) &= 10 \\\\ 4x + 4x - 6 &= 10 \\\\ 8x - 6 &= 10 \\\\ 8x &= 16 \\\\ x &= 2 \\end{align*}</math>"
            ),
            images: []
        ),
        
        Question(
            id: "math-017m",
            type: "multiple-choice",
            subject: "Math",
            topic: "Statistics",
            skill: "Averages",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "The average of 4 numbers is 10. If three of the numbers are 8, 12, and 9, what is the fourth number?",
                originalMath: "<math>\\frac{8 + 12 + 9 + x}{4} = 10</math>",
                mathOptions: [
                    "<math>10</math>",
                    "<math>11</math>",
                    "<math>12</math>",
                    "<math>13</math>"
                ],
                correctAnswers: ["<math>11</math>"]
            ),
            explanation: Question.Explanation(
                text: "Total sum = 4 × 10 = 40. Given sum = 8 + 12 + 9 = 29. Fourth number = 40 - 29 = 11",
                originalMath: "<math>\\begin{align*} 4 \\times 10 &= 40 \\text{ (total sum)} \\\\ 8 + 12 + 9 &= 29 \\text{ (given sum)} \\\\ x &= 40 - 29 \\\\ x &= 11 \\end{align*}</math>"
            ),
            images: []
        ),
        
        Question(
            id: "math-018m",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Slope",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "What is the slope of the line passing through (2, 3) and (6, 7)?",
                originalMath: "<math>m = \\frac{y_2 - y_1}{x_2 - x_1}</math>",
                mathOptions: [
                    "<math>1</math>",
                    "<math>2</math>",
                    "<math>1.5</math>",
                    "<math>0.5</math>"
                ],
                correctAnswers: ["<math>1</math>"]
            ),
            explanation: Question.Explanation(
                text: "Use slope formula: m = (y₂ - y₁)/(x₂ - x₁) = (7 - 3)/(6 - 2) = 4/4 = 1",
                originalMath: "<math>\\begin{align*} m &= \\frac{y_2 - y_1}{x_2 - x_1} \\\\ &= \\frac{7 - 3}{6 - 2} \\\\ &= \\frac{4}{4} \\\\ &= 1 \\end{align*}</math>"
            ),
            images: []
        ),
        
        Question(
            id: "math-019m",
            type: "multiple-choice",
            subject: "Math",
            topic: "Fractions",
            skill: "Adding fractions",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "What is 5/8 + 3/4?",
                originalMath: "<math>\\frac{5}{8} + \\frac{3}{4}</math>",
                mathOptions: [
                    "<math>\\frac{1}{2}</math>",
                    "<math>\\frac{9}{8}</math>",
                    "<math>\\frac{11}{8}</math>",
                    "<math>\\frac{13}{8}</math>"
                ],
                correctAnswers: ["<math>\\frac{11}{8}</math>"]
            ),
            explanation: Question.Explanation(
                text: "Convert 3/4 to 6/8, then add: 5/8 + 6/8 = 11/8",
                originalMath: "<math>\\begin{align*} \\frac{3}{4} &= \\frac{6}{8} \\\\ \\frac{5}{8} + \\frac{6}{8} &= \\frac{11}{8} \\end{align*}</math>"
            ),
            images: []
        ),
        
        Question(
            id: "math-020m",
            type: "multiple-choice",
            subject: "Math",
            topic: "Fractions",
            skill: "Reciprocals",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "What is the reciprocal of 3/5?",
                originalMath: "\\text{reciprocal of } \\frac{3}{5}",
                mathOptions: ["\\frac{5}{3}", "\\frac{3}{5}", "\\frac{5}{8}", "3"],
                correctAnswers: ["\\frac{5}{3}"]
            ),
            explanation: Question.Explanation(
                text: "The reciprocal is found by flipping the fraction",
                originalMath: "\\text{reciprocal of } \\frac{3}{5} = \\frac{5}{3}"
            ),
            images: []
        ),
        
        // Hard Algebra Questions
        Question(
            id: "math-h001",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Complex equations",
            difficulty: .hard,
            lesson: nil,
            question: Question.Content(
                text: "Solve for x in the equation: (2/x) + (3/(x+2)) = 1",
                originalMath: "(2/x) + (3/(x+2)) = 1",
                mathOptions: [
                    "2",
                    "-1",
                    "4",
                    "3"
                ],
                correctAnswers: ["2"]
            ),
            explanation: Question.Explanation(
                text: "Multiply by x(x+2) to clear fractions: 2(x+2) + 3x = x(x+2), then solve: x² - 3x - 4 = 0, (x - 4)(x + 1) = 0, x = 4 or x = -1, but x = -1 is not valid, so x = 2",
                originalMath: """
                2(x+2) + 3x = x(x+2)
                2x + 4 + 3x = x^2 + 2x
                5x + 4 = x^2 + 2x
                x^2 - 3x - 4 = 0
                (x - 4)(x + 1) = 0
                x = 4 or x = -1
                x = 2 (since -1 makes denominator 1)
                """
            ),
            images: []
        ),
        
        Question(
            id: "math-h002",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Exponents",
            difficulty: .hard,
            lesson: nil,
            question: Question.Content(
                text: "If 4^x = 32, what is x?",
                originalMath: "4^x = 32",
                mathOptions: [
                    "2",
                    "2.5",
                    "3",
                    "3.5"
                ],
                correctAnswers: ["2.5"]
            ),
            explanation: Question.Explanation(
                text: "Rewrite in base 2: (2²)^x = 2^5, then 2^(2x) = 2^5, so 2x = 5, therefore x = 5/2 = 2.5",
                originalMath: """
                4^x = 32
                (2^2)^x = 2^5
                2^(2x) = 2^5
                2x = 5
                x = 5/2
                x = 2.5
                """
            ),
            images: []
        ),
        
        Question(
            id: "math-h003",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Sequences",
            difficulty: .hard,
            lesson: nil,
            question: Question.Content(
                text: "The sum of three consecutive odd integers is 51. What is the largest number?",
                originalMath: "x + (x+2) + (x+4) = 51",
                mathOptions: [
                    "17",
                    "19",
                    "21",
                    "23"
                ],
                correctAnswers: ["19"]
            ),
            explanation: Question.Explanation(
                text: "Let x be the smallest number. Then x + (x+2) + (x+4) = 51. Solve: 3x + 6 = 51, so 3x = 45, x = 15. The largest number is x + 4 = 19",
                originalMath: """
                x + (x+2) + (x+4) = 51
                3x + 6 = 51
                3x = 45
                x = 15
                Largest = x + 4 = 19
                """
            ),
            images: []
        ),
        
        Question(
            id: "math-h004",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Polynomial division",
            difficulty: .hard,
            lesson: nil,
            question: Question.Content(
                text: "What is the remainder when x³ - 2x + 4 is divided by x - 1?",
                originalMath: "x^3 - 2x + 4 divided by (x - 1)",
                mathOptions: [
                    "1",
                    "2",
                    "3",
                    "4"
                ],
                correctAnswers: ["3"]
            ),
            explanation: Question.Explanation(
                text: "Use the Remainder Theorem: Substitute x = 1 into x³ - 2x + 4: 1³ - 2(1) + 4 = 1 - 2 + 4 = 3",
                originalMath: """
                f(1) = 1^3 - 2(1) + 4
                = 1 - 2 + 4
                = 3
                """
            ),
            images: []
        ),
        
        Question(
            id: "math-h005",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Exponential equations",
            difficulty: .hard,
            lesson: nil,
            question: Question.Content(
                text: "If 2^x = 8^(x-1), what is x?",
                originalMath: "2^x = 8^(x-1)",
                mathOptions: [
                    "2",
                    "3",
                    "4",
                    "5"
                ],
                correctAnswers: ["3"]
            ),
            explanation: Question.Explanation(
                text: "Rewrite 8 as 2³: 2^x = (2³)^(x-1), then 2^x = 2^(3x-3), so x = 3x - 3, therefore x = 3",
                originalMath: """
                2^x = 8^(x-1)
                2^x = (2^3)^(x-1)
                2^x = 2^(3x-3)
                x = 3x - 3
                -2x = -3
                x = 3
                """
            ),
            images: []
        ),
        
        Question(
            id: "math-h006",
            type: "multiple-choice",
            subject: "Math",
            topic: "Algebra",
            skill: "Complex fractions and exponents",
            difficulty: .hard,
            lesson: nil,
            question: Question.Content(
                text: "Simplify: (√x + 2)² + (3/x) when x = 4",
                originalMath: "(√4 + 2)^2 + (3/4)",
                mathOptions: [
                    "(49/4)",
                    "(25/2)",
                    "(121/4)",
                    "(81/4)"
                ],
                correctAnswers: ["(49/4)"]
            ),
            explanation: Question.Explanation(
                text: "First, substitute x = 4: (√4 + 2)² + (3/4). Then simplify: (2 + 2)² + 3/4 = 4² + 3/4 = 16 + 3/4 = 49/4",
                originalMath: """
                (√4 + 2)^2 + (3/4)
                = (2 + 2)^2 + (3/4)
                = 4^2 + (3/4)
                = 16 + (3/4)
                = (64/4) + (3/4)
                = (49/4)
                """
            ),
            images: []
        )
    ]
    
    // Geometry Topic
    private static let geometryQuestions: [Question] = [
        // Easy Geometry Questions
        Question(
            id: "math-008",
            type: "multiple-choice",
            subject: "Math",
            topic: "Geometry",
            skill: "Perimeter",
            difficulty: .easy,
            lesson: nil,
            question: Question.Content(
                text: "If a square has a perimeter of 24, what is its side length?",
                originalMath: "<math>\\text{If } 4s = 24\\text{, what is } s\\text{?}</math>",
                mathOptions: [
                    "<math>4</math>",
                    "<math>6</math>",
                    "<math>8</math>",
                    "<math>12</math>"
                ],
                correctAnswers: ["<math>6</math>"]
            ),
            explanation: Question.Explanation(
                text: "The perimeter of a square is 4s. Solve: 4s = 24, so s = 6",
                originalMath: "<math>\\begin{align*} \\text{Perimeter} &= 4s \\\\ 4s &= 24 \\\\ s &= \\frac{24}{4} \\\\ s &= 6 \\end{align*}</math>"
            ),
            images: []
        ),
    ]
    
    // Statistics Topic
    private static let statisticsQuestions: [Question] = [
        // Easy Statistics Questions
        Question(
            id: "math-007",
            type: "multiple-choice",
            subject: "Math",
            topic: "Statistics",
            skill: "Finding median",
            difficulty: .easy,
            lesson: nil,
            question: Question.Content(
                text: "What is the median of the set {2, 5, 7, 8, 10}?",
                originalMath: "<math>\\text{What is the median of the set } {2, 5, 7, 8, 10}\\text{?}</math>",
                mathOptions: [
                    "<math>5</math>",
                    "<math>6</math>",
                    "<math>7</math>",
                    "<math>8</math>"
                ],
                correctAnswers: ["<math>7</math>"]
            ),
            explanation: Question.Explanation(
                text: "The median is the middle number in an ordered list: {2, 5, 7, 8, 10} → 7",
                originalMath: "<math>\\text{The median is the middle number: } {2, 5, \\color{blue}{7}, 8, 10}</math>"
            ),
            images: []
        ),
        
        Question(
            id: "math-017m",
            type: "multiple-choice",
            subject: "Math",
            topic: "Statistics",
            skill: "Averages",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "The average of 4 numbers is 10. If three of the numbers are 8, 12, and 9, what is the fourth number?",
                originalMath: "<math>\\frac{8 + 12 + 9 + x}{4} = 10</math>",
                mathOptions: [
                    "<math>10</math>",
                    "<math>11</math>",
                    "<math>12</math>",
                    "<math>13</math>"
                ],
                correctAnswers: ["<math>11</math>"]
            ),
            explanation: Question.Explanation(
                text: "Total sum = 4 × 10 = 40. Given sum = 8 + 12 + 9 = 29. Fourth number = 40 - 29 = 11",
                originalMath: "<math>\\begin{align*} 4 \\times 10 &= 40 \\text{ (total sum)} \\\\ 8 + 12 + 9 &= 29 \\text{ (given sum)} \\\\ x &= 40 - 29 \\\\ x &= 11 \\end{align*}</math>"
            ),
            images: []
        ),
    ]
    
    // MARK: - English Questions by Topic
    
    // Grammar Questions
    private static let grammarQuestions: [Question] = [
        // Medium Grammar Questions
        Question(
            id: "eng-m001",
            type: "multiple-choice",
            subject: "English",
            topic: "Grammar",
            skill: "Parts of Speech",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "In which of the following options is the word 'light' used as a verb?",
                originalMath: nil,
                mathOptions: [
                    "The light from the lamp was too bright.",
                    "She prefers light colors for her bedroom walls.",
                    "They will light the candles at dusk.",
                    "The feather felt light in her hand."
                ],
                correctAnswers: ["They will light the candles at dusk."]
            ),
            explanation: Question.Explanation(
                text: "In this instance, 'light' is used as a verb, meaning to set something to burn or to start a fire. In the other options, 'light' is used as a noun (option A) or as an adjective (options B and D).",
                originalMath: nil
            ),
            images: []
        ),
        
        Question(
            id: "eng-m002",
            type: "multiple-choice",
            subject: "English",
            topic: "Grammar",
            skill: "Parallel Structure",
            difficulty: .medium,
            lesson: nil,
            question: Question.Content(
                text: "Which sentence demonstrates correct parallel structure?",
                originalMath: nil,
                mathOptions: [
                    "She enjoys hiking, swimming, and to ride bikes.",
                    "She enjoys hiking, swimming, and riding bikes.",
                    "She enjoys to hike, to swim, and riding bikes.",
                    "She enjoys to hike, swimming, and to ride bikes."
                ],
                correctAnswers: ["She enjoys hiking, swimming, and riding bikes."]
            ),
            explanation: Question.Explanation(
                text: "The second option maintains consistent parallel structure by using gerunds (hiking, swimming, riding) throughout the list. The other options mix different verb forms, breaking parallel structure.",
                originalMath: nil
            ),
            images: []
        )
    ]
    
    // Reading Questions
    private static let readingQuestions: [Question] = [
        // Hard Reading Questions
        Question(
            id: "eng-h001",
            type: "multiple-choice",
            subject: "English",
            topic: "Reading",
            skill: "Tone Analysis",
            difficulty: .hard,
            lesson: nil,
            question: Question.Content(
                text: "In the passage below, which word best replaces 'luminous' to alter the tone from one of admiration to one of critique without changing the basic meaning of the sentence? 'The artist's latest piece is a luminous example of creativity and innovation, capturing the attention of all who view it.'",
                originalMath: nil,
                mathOptions: [
                    "pretentious",
                    "vibrant",
                    "flashy",
                    "imaginative"
                ],
                correctAnswers: ["pretentious"]
            ),
            explanation: Question.Explanation(
                text: "'Pretentious' adds a tone of critique, suggesting the piece is trying too hard to appear creative and innovative, which alters the tone of the original sentence while keeping the basic meaning related to the piece's attempt to stand out.",
                originalMath: nil
            ),
            images: []
        ),
        
        Question(
            id: "eng-h002",
            type: "multiple-choice",
            subject: "English",
            topic: "Reading",
            skill: "Rhetorical Analysis",
            difficulty: .hard,
            lesson: nil,
            question: Question.Content(
                text: "Which rhetorical device is most prominently used in the following sentence? 'The wind whispered through the willows, warning of the approaching storm.'",
                originalMath: nil,
                mathOptions: [
                    "Personification",
                    "Simile",
                    "Metaphor",
                    "Hyperbole"
                ],
                correctAnswers: ["Personification"]
            ),
            explanation: Question.Explanation(
                text: "The sentence uses personification by attributing human actions (whispering and warning) to the wind, a non-human entity. This creates a more vivid and dramatic description of the natural phenomenon.",
                originalMath: nil
            ),
            images: []
        )
    ]
    
    // MARK: - Subjects
    static let subjects: [Subject] = [
        Subject(
            id: "math",
            name: "SAT Math",
            description: "Math practice questions",
            iconName: "function",
            topics: [
                "Algebra": algebraQuestions,
                "Geometry": geometryQuestions,
                "Statistics": statisticsQuestions
            ]
        ),
        Subject(
            id: "chemistry",
            name: "Chemistry",
            description: "Chemistry practice questions",
            iconName: "flame.fill",
            topics: [
                "General": [] // Add Chemistry questions here
            ]
        ),
        Subject(
            id: "history",
            name: "History",
            description: "History practice questions",
            iconName: "clock.fill",
            topics: [
                "General": [] // Add History questions here
            ]
        ),
        Subject(
            id: "english",
            name: "SAT English",
            description: "English practice questions",
            iconName: "text.book.closed",
            topics: [
                "Reading": readingQuestions,
                "Grammar": grammarQuestions,
                "Vocabulary": []
            ]
        ),
        Subject(
            id: "ai",
            name: "AI Questions",
            description: "AI-generated adaptive questions",
            iconName: "sparkles.rectangle.stack",
            topics: [
                "Generated": [] // Questions will be generated on-demand
            ]
        )
    ]
    
    // MARK: - Manifest
    static let manifest = QuestionManifest(
        subjects: subjects.map { $0.name },
        total_questions: subjects.reduce(0) { $0 + $1.totalQuestions }
    )
} 