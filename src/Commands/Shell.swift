import Foundation
import AppKit

class Shell: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'shell'."
    
    /** The output generated by an execution. */
    struct ExecutionOutput {
        /** The output to stdout. */
        let stdout: String?
        /** The outputu to stderr. */
        let stderr: String?
        /** The executions exit status. */
        let exitStatus: Int32
    }
    
    /** The list of commands which this instance executes. */
    private let commands: [String]
    
    /**
     Creates a new shell command which can sequentially execute a list of commands.
     
     - Parameter commands: A non-empty list of commands.
     - ToDo: Error handling.
     */
    init(_ commands: [String]) {
        assert(commands.count > 0, "Expected a command for execution.")
        self.commands = commands
    }
    
    /**
     Executes the list of shell commands.
     - Precondition: The app calling this function must have a Resources directory.
     - Parameter sender: This function's caller.
     - Throws: An NSInvalidArgumentException if the binary invalid or if it fails to to be executed.
     */
    func execute(sender: NSObject) {
        for command in commands {
            do {
                let arguments = try Parser.parse(arguments: command)
                let output = try Shell.execute(binary: "/usr/bin/env", arguments: arguments)
                guard output.exitStatus == EXIT_SUCCESS else {
                    // TODO error handling.
                    preconditionFailure("Not implemented.")
                }
            } catch {
                // TODO error handling.
                preconditionFailure("Not implemented.")
            }
        }
    }
    
    /**
     Executes a shell command.
     - Parameters:
        - binary: The command to be executed. Defaults to `/bin/sh`.
        - arguments: C-Style arguments, if any, to the command to be executed.
        - workingDirectory: The execution's working directory.
        Defaults to the main bundle's resource directory.
     - Requires: The app calling this function must have a Resources directory.
     - Throws: An NSInvalidArgumentException if the binary invalid or if it fails to to be executed.
     - Returns: The stdout, the stderr and the exit code obtained by executing the binary.
     */
    static func execute(binary: String = "/usr/bin/env",
                 arguments: [String]? = nil,
                 workingDirectory: URL = Bundle.main.resourceURL!) throws -> ExecutionOutput {
        let process = Process()
        process.arguments = arguments
        
        let bin = "\(Bundle.main.bundlePath)/Contents/Resources/app/bin"
        var environment = ProcessInfo.processInfo.environment
        let path = environment["PATH"] ?? nil
        environment["PATH"] = path != nil && !path!.isEmpty
            ? "\(bin):\(path!)"
            : bin
        process.environment = environment

        
        if #available(OSX 10.13, *) {
            process.currentDirectoryURL = workingDirectory
            process.executableURL = URL(fileURLWithPath: binary)
        } else {
            process.currentDirectoryPath = workingDirectory.path
            process.launchPath = binary
        }
        
        let stdout = Pipe()
        let stdoutHandle = stdout.fileHandleForReading
        process.standardOutput = stdout
        
        let stderr = Pipe()
        let stderrHandle = stderr.fileHandleForReading
        process.standardError = stderr
        
        process.launch()
        process.waitUntilExit()
        
        let stderrData = stderrHandle.readDataToEndOfFile()
        let stdoutData = stdoutHandle.readDataToEndOfFile()
        let output = ExecutionOutput(stdout: String(data: stdoutData, encoding: String.Encoding.utf8),
                            stderr: String(data: stderrData, encoding: String.Encoding.utf8),
                            exitStatus: process.terminationStatus)
        return output
    }
}
