import subprocess
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def run_command(command):
    try:
        logger.info("Running shell command: \"{}\"".format(command))
        result = subprocess.run(command, shell=True, stdout=subprocess.PIPE)
        logger.info("Command output:\n---\n{}\n---".format(result.stdout.decode('UTF-8')))
    except Exception as e:
        logger.error("Exception: {}".format(e))
        return False

    return True

def lambda_handler(event, context):
    # I've added a layer to the Lambda function that includes the awscli package.
    # This allows us to run shell commands like 'aws s3' directly, for future functionality I haven't of yet.
    # It is installed under the /opt directory in the Lambda environment.
    
    domain = event.get('domain')
    run_command('nslookup' + domain)
