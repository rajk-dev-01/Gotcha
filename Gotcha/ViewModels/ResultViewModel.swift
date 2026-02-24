//
//  ResultViewModel.swift
//  Gotcha
//
//  MVVM - ViewModel for the receipt list and search flow
//

import SwiftUI
import Combine

@MainActor
final class ResultViewModel: ObservableObject {
    // MARK: - Published State
    @Published var searchText: String = ""
    @Published var debouncedText: String = ""
    @Published var selectedImage: UIImage?
    @Published var selectedItem: ReceiptItem?
    
    @Published var showScanner = false
    @Published var showPhotoPicker = false
    @Published var addNew = false
    @Published var navigateToSaveAs = false
    @Published var navigateToDetails = false
    
    // MARK: - Private
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupDebounce()
    }
    
    private func setupDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.debouncedText = value
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    func clearSearch() {
        searchText = ""
        debouncedText = ""
    }
    
    func selectReceipt(_ item: ReceiptItem) {
        selectedItem = item
        navigateToDetails = true
    }
    
    func presentScanner() {
        showScanner = true
    }
    
    func presentPhotoPicker() {
        showPhotoPicker = true
    }
    
    func onAddNew() {
        addNew = true
    }
    
    func onAddOptionCamera() {
        addNew = false
        showScanner = true
    }
    
    func onAddOptionLibrary() {
        addNew = false
        showPhotoPicker = true
    }
    
    func onImageSelectedForSave(_ image: UIImage) {
        selectedImage = image
        navigateToSaveAs = true
    }
    
    func cancelAdd() {
        addNew = false
    }
    
    func dismissSearchFocus() {
        searchText = ""
        debouncedText = ""
    }
}
