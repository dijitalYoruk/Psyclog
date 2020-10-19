const { catchAsync } = require('../utils/ErrorHandling')
const PatientNote = require('../model/patientNote')
const ApiError = require('../utils/ApiError')
const { isMatching } = require('../utils/util')


const createPatientNote = catchAsync(async (req, res, next) => {
    const psychologist = req.currentUser
    const { patient, content } = req.body

    // check if psychologist has the patient.
    if (!psychologist.patients.includes(patient)) {
        return next(new ApiError(__('error_unauthorized'), 403))
    }

    const note = new PatientNote({
        psychologist: psychologist._id,
        patient, content
    })

    await note.save()
    
    res.status(200).json({
        status: 200,
        data: { 
            message: __('success_create', 'Note')
        } 
    })    
})


const retrievePatientNotes = catchAsync(async (req, res, next) => {
    const psychologist = req.currentUser
    const { patient } = req.query

    // check if psychologist has the patient.
    if (!psychologist.patients.includes(patient)) {
        return next(new ApiError(__('error_unauthorized'), 403))
    }

    const notes = await PatientNote.find({ psychologist: psychologist._id, patient })
                                   .sort('createdAt')

    res.status(200).json({
        status: 200,
        data: { notes } 
    })    
})

const updatePatientNote = catchAsync(async (req, res, next) => {
    const psychologist = req.currentUser
    const { noteId, content } = req.body
    const patientNote = await PatientNote.findById(noteId)

    // check if psychologist has the patient.
    if (!psychologist.patients.includes(patientNote.patient) || 
        !isMatching(patientNote.psychologist, psychologist._id)) {
        return next(new ApiError(__('error_unauthorized'), 403))
    }
    
    patientNote.content = content
    await patientNote.save()

    res.status(200).json({
        status: 200,
        data: { patientNote } 
    })    
})

const deletePatientNote = catchAsync(async (req, res, next) => {
    const psychologist = req.currentUser
    const { noteId } = req.body
    const patientNote = await PatientNote.findById(noteId)

    // check if psychologist has the patient.
    if (!psychologist.patients.includes(patientNote.patient) || 
        !isMatching(patientNote.psychologist, psychologist._id)) {
        return next(new ApiError(__('error_unauthorized'), 403))
    }
    
    await patientNote.remove()

    res.status(204).json({
        status: 204,
        data: { message: __('success_delete', 'Note') }
    })    
})

module.exports = {
    createPatientNote,
    deletePatientNote,
    updatePatientNote,
    retrievePatientNotes,
}