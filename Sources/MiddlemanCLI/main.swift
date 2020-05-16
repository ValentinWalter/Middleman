import ArgumentParser

struct Middleman: ParsableCommand {
    @Argument() var msg: String

    func run() throws {
        print("\(msg) yay!")
    }
}
