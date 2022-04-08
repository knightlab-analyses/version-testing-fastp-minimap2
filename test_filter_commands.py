import gzip
import unittest
import subprocess
import os

class TestPreProcessing(unittest.TestCase):
    def setUp(self):
	# params for the test
        self.curr_path = os.path.dirname(os.path.abspath(__file__))
        self.output_path = self.curr_path + "/data"
        self.file_one = self.output_path + "/all_reads_R1.fq"
        self.file_two = self.output_path + "/all_reads_R2.fq"
        self.database_path = self.curr_path
        self.db_one_name = "human-phix-db"
        self.db_two_name = "chm13"
        pass

    def test_command(self):
        """Test command completes."""
        # run command
        res_cmnd = subprocess.run(["./test-command.sh",
                                   self.file_one,
                                   self.file_two,
                                   self.database_path,
                                   self.db_one_name,
                                   self.db_two_name,
                                   self.output_path])
        self.assertTrue(res_cmnd.returncode == 0)

    def test_filter_results(self):
        """Test command results match expectation."""
        # base truth
        with open(self.output_path + '/host_read_ids.txt') as file:
            exp_lines = [line.replace('\n','') for line in file.readlines()]
        # check file size (should be much greater than 100 bytes)
        out_size = os.path.getsize(self.output_path + '/test_res_R1.trimmed.fastq.gz')
        self.assertTrue(out_size > 100)
        # results
        with gzip.open(self.output_path + '/test_res_R1.trimmed.fastq.gz','r') as fin:
            res_lines = [line.decode("utf-8").replace('\n','') for line in fin if '@' in str(line)]
        # check there are no host reads passing filter
        rel_tol = len(set(res_lines) & set(exp_lines)) / len(set(exp_lines)) * 100
        self.assertTrue(rel_tol < 0.1)
	# finally remove files
        os.remove(self.curr_path + "/fastp.html")
        os.remove(self.curr_path + "/fastp.json")
        os.remove(self.output_path + "/test_res_R1.trimmed.fastq.gz")
        os.remove(self.output_path + "/test_res_R2.trimmed.fastq.gz")


if __name__ == "__main__":
    unittest.main()
