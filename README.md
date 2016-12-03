# cdss-app-tstool-test #

This repository contains functional tests for the TSTool software.  TSTool is software developed for [Colorado's Decision Support Systems (CDSS)](http://cdss.state.co.us) and
is [available from the Open Water Foundation](http://openwaterfoundation.org/software-tools/tstool) and [from CDSS](http://cdss.state.co.us/software/Pages/TSTool.aspx).

TSTool functional tests consist of TSTool command files and test data used in automated regression tests.  The purpose of these tests is to validate TSTool command functionality for default command parameters and combinations of user-specified command parameter values.
The tests are also helpful for understanding how to use TSTool commands and can therefore be used as a reference.

TSTool quality control is discussed in the "Quality Control" chapter in the TSTool User Manual, available when the software is installed.  The following discuss important points.

## Cloning the Repository

Because the tests can be run from any folder, the repository can be cloned into any folder.

If the tests are being included in a TSTool Eclipse development workspace, then clone the repository into a folder parallel to other TSTool component repositories so that the tests can be conveniently run from the developer environment.

**Warning - there are thousands of tests so cloning the full repository will result in many files.  Evaluate whether individual test files should be downloaded instead.**

## Repository File Structure

The important files in the repository are as follows (other files can generally be ignored):

```text
test/                                       (Top-level folder for all tests)
  regression/                               (Top-level folder for automated regression tests)
    commands/                               (Folder containing command tests)
      general/                              (General - meaning general commands, although could
                                             use this folder level to categorize if that made sense)
        CommandName/                        (Command name, as in TSTool)
          Data/                             (Data used for command tests, usually small datasets)
          ExpectedResults/                  (Expected output from test when files are involved,
                                             generated, inspected, and saved for continued use)
          Results/                          (Results generated by the current test runs)
          Test_CommandName_TestName.TSTool  (Individual test command files to run)
    TestSuites/                             (Folder for saving test suites, when the above command
                                             tests are run in groups)
      commands_general/                     (Folder for general command test suite, basically to
                                             run all commands from above)
        create/                             (Includes TSTool command files to create the test suite)
        run/                                (Includes auto-generated test suite to run many command tests)
    
```

It is undesirable to store dynamic test results in the repository.  Therefore, each `Results` folder includes a `.gitignore` file to ignore all files in the folder, except for the `.gitignore` file itself.  Other approaches were evaluated and may be implemented in the future; however, using individual `.gitignore` files is fail-safe.  The empty `Results` folders will be available if the repository is cloned.  This is helpful because TSTool commands do not generally auto-generate output folders.

See the [Configuring a Test](#configuring-a-test) section for more information about a test.

## Running the Tests

The functional tests are run by the TSTool software from the development environment or a normal install.
Tests can be run from the TSTool user interface or in batch mode.
This approach allows TSTool to test itself as well as being used to test essentially any workflow process that can be run by TSTool,
including running external programs.
The advantage of this approach is that TSTool users can create automated tests without having to install
and be proficient with the TSTool software development environment.

### Run a Single Test

Running a single test is the approach taken when doing test-driven development.  This is particularly efficient given that TSTool provides a list of previously-opened command files and the top choice can be selected when TSTool is started.  Although unit tests in the code could be implemented, function tests validate the full software functionality and ensure that tests are created that can be run in the operational environment, if needed.

To run a single test in the TSTool user interface, use the TSTool ***File / Open / Command File*** menu and browse to the location of one of the command `*.TSTool` test files.  Once loaded into the TSTool interface, use the ***Run All  Commands*** button.  If the test is successful, no red or yellow markers will be shown.  Note that some tests are structured to generate an error or warning on purpose in which case an `#@expectedStatus` comment will usually be found at the top of the test command file.
Whether or not the test is considered a pass or fail depends on the expected and actual result of running the command file.

### Run a Test Suite

Running the general commands test suite is the approach taken to verify software functionality before a  software release.  Because some tests require a database connection or other setup (done outside of the individual test), it can be difficult to run the full test suite for all tests.  In some cases a subset will be run based on specific system setup.  These are details that TSTool maintainers are familiar with.

To run the full test suite for all commands, use the TSTool ***File / Open / Command File*** menu and browse to the `TestSuites/commands_general/run` folder and select `RunRegressionTest_commands_general_IncludeOS=Widows.TSTool` (or similar test suite).
Once loaded into the TSTool interface, use the ***Run All Commands*** button.
This will create several output files summarizing test results, with the following considerations:

* Some tests always fail - these are tests that need additional attention and are left in so that they are not forgotten.  Generally they are seldom used or legacy commands that need more attention.

* Some tests are expected to fail and will generate warning and/or failure indicators.  However, the true indication of whether a test passed is whether the output results match the expected results.

* Text report, csv, and Excel output files are generated to facilitate reviewing the results.

The test suite can also be run in batch mode with `TSTool -commands xxx.TSTool`.  However, this has not traditionally been done because the TSTool development has not used continuous integration and tests that currently always fail would need to be cleaned up.

## Configuring a Test

Each TSTool test is a command file that is intended to test the functionality of a single command or some reasonably small combination of commands.  Command files typically include the following steps involving TSTool commands:

* Setup step(s), such as opening a log file and defining synthetic time series data with the `NewTimeSeries` or `NewPatternTimeSeries` commands.  In some cases, data are read from files using various `Read...` commands (input is generally stored in the `Data` folder under the command test folder).
* Execution step(s), in particular running the command to be tested, which will modify in-memory data and/or write output to file(s).
* Test/comparison step(s), for example using the `CompareTimeSeries`, `CompareFiles`, or other command.  These are equivalent to unit test "assert" tests commonly used in software testing.
* Teardown/cleanup step(s), such as removing files or freeing in-memory data objects.  However, because dynamic test result output is not saved to the Git repository, there is generally not a need to do much tear-down.  A specific example where tear-down is appropriate is when testing the `SetDebugLevel` command it is necessary to turn debugging off after the test so that subsequent commands don't run in debug mode, which generates a lot of output and is slow.

Refer to the command tests for examples of how the above template is implemented.  Newer tests include better comments.