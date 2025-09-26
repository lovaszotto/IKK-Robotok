from flask import Flask, request
import subprocess

app = Flask(__name__)

@app.route('/run-robot', methods=['POST'])
def run_robot():
    try:
        # Futtatja a robotot log, report és output nélkül
        result = subprocess.run(
            ['robot', '--log', 'NONE', '--report', 'NONE', '--output', 'NONE', 'PLG-00-main.robot'],
            capture_output=True, text=True, timeout=600
        )
        if result.returncode == 0:
            return "Robot sikeresen lefutott!\n\n" + result.stdout
        else:
            return "Robot futás közben hiba történt!\n\n" + result.stdout + "\n" + result.stderr
    except Exception as e:
        return f"Hiba: {e}"

@app.route('/')
def index():
    return open('web/robot_runner.html', encoding='utf-8').read()

if __name__ == '__main__':
    app.run(port=5000, debug=True)
