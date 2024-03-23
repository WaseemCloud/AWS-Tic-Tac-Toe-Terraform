const board = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '];

function displayBoard() {
  const cells = document.querySelectorAll('.cell');
  for (let i = 0; i < board.length; i++) {
    cells[i].innerText = board[i];
  }
}

function makeMove(index) {
  if (board[index] === ' ' && !isGameOver()) {
    board[index] = 'X';
    displayBoard();
    if (!isGameOver()) {
      aiMove();
      displayBoard();
    }
  }
}

function aiMove() {
  const apiUrl = 'API-INVOKE-URL';  // Replace with your API endpoint URL

   console.log('Making AI move request...');

  const requestBody = {
    body: JSON.stringify({
      board: board
    })
  };

  fetch(apiUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(requestBody)
  })
    .then(response => response.json())
    .then(data => {
      console.log('AI move response:', data);

      const parsedData = JSON.parse(data.body);  // Parse the response body
	  const aiMoveIndex = parsedData.ai_move;  // Get the AI move index

    console.log('AI move index:', aiMoveIndex);

    if (!isNaN(aiMoveIndex) && board[aiMoveIndex] === ' ' && !isGameOver()) {
		board[aiMoveIndex] = 'O';
		displayBoard();
		isGameOver();
    }
  })
  .catch(error => console.error('Error:', error));
}



function isGameOver() {
  // Check for a win
  const winningPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],  // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8],  // columns
    [0, 4, 8], [2, 4, 6]  // diagonals
  ];

  for (const pattern of winningPatterns) {
    const [a, b, c] = pattern;
    if (board[a] !== ' ' && board[a] === board[b] && board[b] === board[c]) {
      // A win is detected
      displayResult(board[a]);
      return true;
    }
  }

  // Check for a tie
  if (!board.includes(' ')) {
    displayResult('tie');
    return true;
  }

  return false;
}

function displayResult(result) {
  const resultText = document.getElementById('result');
  resultText.innerHTML = '';  // Clear any previous content

  if (result === 'tie') {
    resultText.innerText = 'It\'s a tie!';
  } else if (result === 'X') {
    resultText.innerText = 'You won!';
  } else {
    resultText.innerText = 'You lost!';
  }
}


function resetGame() {
  for (let i = 0; i < board.length; i++) {
    board[i] = ' ';
  }
  displayBoard();
  // Clear the result display
  const resultText = document.getElementById('result');
  resultText.innerText = '';
}
