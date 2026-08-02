
function fn() {

    var notepad = {
        notes : {}
    }

    notepad.set = function (key, value) {
            notepad.notes[key] = value;
            Java.type('utils.SetEnvironment').set('notepad', JSON.stringify(notepad.notes))
    };

    notepad.get = function (key) {
        try{
            return JSON.parse(Java.type('utils.SetEnvironment').get('notepad'))[key]
        }catch(e){
            return ''
        }
    };

    notepad.getAll = function () {
        return JSON.parse(Java.type('utils.SetEnvironment').get('notepad'))
    };
    return notepad
}